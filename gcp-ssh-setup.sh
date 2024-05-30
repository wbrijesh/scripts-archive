#!/bin/bash

# Update sshd_config to allow root login with key
sudo sed -i 's/PermitRootLogin no/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config

# Create .ssh directory for root user
sudo mkdir -p /root/.ssh

# Set permissions for .ssh directory
sudo chmod 700 /root/.ssh

# Create authorized_keys file
sudo touch /root/.ssh/authorized_keys

# Set permissions for authorized_keys file
sudo chmod 600 /root/.ssh/authorized_keys

# Take user input for SSH key and append to authorized_keys file
echo "Please paste your SSH public key below and press Enter:"
read ssh_key
echo "$ssh_key" | sudo tee -a /root/.ssh/authorized_keys >/dev/null

echo "SSH key has been added to /root/.ssh/authorized_keys."

echo "Restarting SSH service..."
sudo systemctl restart ssh
