#!/bin/bash
sudo yum update -y

# Install helpers
sudo yum install yum-utils telnet -y

# Install Java
sudo yum install java-11-openjdk-devel -y

# Install Docker
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
sudo systemctl start docker

# Pull docker images
docker pull dig0w/letscode_fe
docker pull dig0w/letscode_be

# Running docker images
docker run -p 80:80 dig0w/letscode_fe
docker run -p 8080:8080 -p 443:443 -e MYSQL_DB_HOST=MYSQL_DB_HOST -e MYSQL_DB_USER=letscode -e MYSQL_DB_PASS="7ROtBB44*0XN" dig0w/letscode_be