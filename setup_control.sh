#!/usr/bin/env bash

# Generate ssh key pair
sudo mkdir ~/.ssh/
cd /home/vagrant/.ssh/
ssh-keygen -f id_rsa -t rsa -N ''
eval $(ssh-agent -s) && ssh-add ~/.ssh/id_rsa
cp /home/vagrant/.ssh/id_rsa.pub /vagrant/control.pub
chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
#sudo restorecon -R -v ~/.ssh
echo "SSH key pair generation finished!"

# Install some tools
sudo apt-get update
sudo apt-get install -y unzip vim tmux software-properties-common curl wget rsync

# Install Ansible
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main" | sudo tee /etc/apt/sources.list.d/ansible.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
sudo apt-get update
sudo apt-get install ansible -y
echo "Ansible installation finished!"

# Install terraform
echo "Terraform installation started!"
curl -Ls "http://releases.hashicorp.com/terraform/0.8.8/terraform_0.8.8_linux_amd64.zip" -o /tmp/terraform.zip -k --insecure -v
sudo unzip /tmp/terraform.zip -d /opt/terraform
rm -f /tmp/terraform.zip
sudo ln -s /opt/terraform/terraform /usr/bin/terraform
echo "Terraform installation finished!"

# Configure control host PS1
echo 'PS1="\[\e[00;33m\][\[\e[0m\]\[\e[00;35m\]\t\[\e[0m\]\[\e[00;33m\]]\[\e[0m\]\[\e[00;37m\] \[\e[0m\]\[\e[00;36m\]\u\[\e[0m\]\[\e[00;31m\]@\[\e[0m\]\[\e[00;32m\]\H\[\e[0m\]\[\e[00;37m\]\n\[\e[0m\]\[\e[01;36m\]\\$\[\e[0m\]\[\e[01;34m\]:\[\e[0m\]\[\e[00;33m\]\w\[\e[0m\]\[\e[01;34m\]:\[\e[0m\]\[\e[01;31m\]\$?\[\e[0m\]\[\e[00;31m\]>\[\e[0m\]\[\e[00;37m\] \[\e[0m\]"' >> ~/.bashrc
