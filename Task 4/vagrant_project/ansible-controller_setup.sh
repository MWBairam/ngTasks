#! /bin/sh

# In a VM created by vagrant, a directory /vagrant will be created with the Vagrantfile and other files copied to it.
# Then

cp /vagrant/ansible-controller_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y

apt install -y python-jinja2 python-pip libssl-dev curl vim 
pip install -U pip
apt install ansible ansible-galaxy 


reboot
