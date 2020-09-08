#!/bin/bash

# Preparation
sudo apt-get update
sudo apt-get upgrade -y
sudo apt install -y python3-pip -y

# doctl
cd ~/ && rm -R ~/doctl
cd ~/ && mkdir doctl && cd doctl
curl -LO https://github.com/digitalocean/doctl/releases/download/v1.45.1/doctl-1.45.1-linux-amd64.tar.gz 
tar -xvf doctl-1.45.1-linux-amd64.tar.gz
sudo mv ~/doctl/doctl /usr/local/bin

# Update .bashrc
cd ~
echo "alias cls='clear'" >> ~/.bashrc
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kga='kubectl get all'" >> ~/.bashrc

reboot

# End of Script