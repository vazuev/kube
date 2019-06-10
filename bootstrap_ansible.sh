
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
sudo apt-get install -y unzip vim tmux software-properties-common curl wget rsync git python-pip python3-pip
# sudo snap install kubeadm --classic
#python-minimal


# Install Ansible
# sudo apt-add-repository --yes --update ppa:ansible/ansible
# sudo apt-add-repository --yes ppa:ansible/ansible
# sudo apt-get update
# sudo apt-get install ansible -y
# echo "Ansible installation finished!"

curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
echo "kubectl installation finished!"


cd /home/vagrant/src
git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray
pip3 install ruamel_yaml==0.15.97  --user
pip install -r requirements.txt --user

# pip3 install --upgrade cryptography --user
# pip3 install ruamel_yaml==0.15.97  --user
# pip3 install -r requirements.txt --user

