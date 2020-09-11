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

# Update Message of the Day
echo "Reference commands to the various URLs in this tutorial" >> /etc/motd
echo "*************************************************************************************" >> /etc/motd
echo "* Online Boutique is here: echo $BOUTIQUE_LB                                        *" >> /etc/motd
echo "* Octant is here: echo $DROPLET_ADDR:8900                                           *" >> /etc/motd
echo "* Grafana is here: echo $GRAFANA_LB                                                 *" >> /etc/motd
echo "* Locust is here: echo $DROPLET_ADDR:8089                                           *" >> /etc/motd
echo "* Start in another shell : octant &                                                 *" >> /etc/motd
echo "* Start in another shell: locust --host="http://${BOUTIQUE_LB}" -u "${USERS:-10}" & *" >> /etc/motd
echo "* Add this to .bashrc manually 'PS1='[\u@\h \w $(kube_ps1)]\$ '                     *" >> /etc/motd
echo "*************************************************************************************" >> /etc/motd

reboot

# End of Script