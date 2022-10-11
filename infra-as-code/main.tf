terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# # 1. Create vpc
resource "aws_vpc" "dev-vpc" {
cidr_block = "172.16.1.0/25"
  tags = {
    Name = "dev"
  }
}

#2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.dev-vpc.id

}

# # 3. Create Custom Route Table
resource "aws_route_table" "dev-route-table" {
  vpc_id = aws_vpc.dev-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Dev"
  }
}

# # 4. Create a Subnet1
resource "aws_subnet" "public-subnet" {
  count = length(var.public_subnets)
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block = var.public_subnets[count.index]
  availability_zone = var.subnets_availability_zones[count.index]

  tags = {
    Name = "public-${count.index}"
  }
}

resource "aws_subnet" "private-subnet" {
  count = length(var.private_subnets)
  vpc_id            = aws_vpc.dev-vpc.id
  cidr_block = var.private_subnets[count.index]
  availability_zone = var.subnets_availability_zones[count.index]

  tags = {
    Name = "private-${count.index}"
  }
}

# # 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  count = length(var.public_subnets)
  subnet_id      = aws_subnet.public-subnet[count.index].id
  route_table_id = aws_route_table.dev-route-table.id
}

# # # 5. Associate subnet with Route Table
# resource "aws_route_table_association" "a2" {
#   subnet_id      = aws_subnet.public-subnet-2.id
#   route_table_id = aws_route_table.dev-route-table.id
# }


# # # 5. Associate subnet with Route Table
# resource "aws_route_table_association" "a3" {
#   subnet_id      = aws_subnet.public-subnet-3.id
#   route_table_id = aws_route_table.dev-route-table.id
# }


# # 6. Create Security Group to allow port 22,80,443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow Web inbound traffic"
  vpc_id      = aws_vpc.dev-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# # 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  count = length(var.public_subnets)
  subnet_id       = aws_subnet.public-subnet[count.index].id
  security_groups = [aws_security_group.allow_web.id]

}

# # 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.web-server-nic[0].id
  depends_on                = [aws_internet_gateway.gw]
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# # 9. Create Ubuntu server
resource "aws_instance" "web-server-instance" {
  ami               = "ami-06640050dc3f556bb" # Ubuntu 18.04
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = aws_key_pair.deployer.key_name

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.web-server-nic[0].id
  }

  #   user_data = <<-EOF
  #                 #!/bin/bash
  #                 sudo apt update -y
  #                 sudo apt install apache2 -y
  #                 sudo systemctl start apache2
  #                 sudo bash -c 'echo your very first web server > /var/www/html/index.html'
  #                 EOF
  tags = {
    Name = "web-server"
  }
}

output "server_public_ip" {
  value = aws_eip.one
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip

}

output "server_id" {
  value = aws_instance.web-server-instance.id
}