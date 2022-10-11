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