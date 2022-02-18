#! /bin/sh

# In a VM created by vagrant, a directory /vagrant will be created with the Vagrantfile and other files copied to it.
# Then

cp /vagrant/ng-vm2_interfaces /etc/network/interfaces
cp /vagrant/hosts /etc/hosts
cp /vagrant/grub /etc/default/grub

update-grub

apt update -y
apt upgrade -y


reboot
