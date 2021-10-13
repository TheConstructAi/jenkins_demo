#!/bin/bash

# Exit on any error. If something fails, there's no use
# proceeding further because Jenkins might not be able 
# to run in that case
set -e

# Install openssh server
sudo apt-get update -y || true
sudo apt-get install -y openssh-server

# Config openssh server and start it
sudo chmod 666 /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config
sudo service ssh restart

# Make some mods so we won't run into problems
# when connecting
cd ~
if [ ! -f .bash_aliases ]; then
    mv .bash_aliases .bash_aliases.bup
fi

# Prepare ssh keys
# Create it in the user workspace so we can store it
cd ~/webpage_ws
if [ ! -f id_rsa ]; then
    ssh-keygen -q -N '' -C '' -f id_rsa
fi

# Copy the ssh key to the ~/.ssh directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh 
cd ~/.ssh
if [ ! -f id_rsa ]; then
    cp ~/webpage_ws/id_rsa .
    cp ~/webpage_ws/id_rsa.pub .
    chmod 600 id_rsa
    cat id_rsa.pub >> authorized_keys
    chmod 600 authorized_keys
fi

# Start the ssh agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

# print the ssh keys
cat id_rsa
echo ''
cat id_rsa.pub

# config git
git config --global user.name 'Jenkins Course'
git config --global user.email 'jenkins@theconstruct.ai'
