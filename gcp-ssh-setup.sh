#!/bin/bash

# Check if an SSH key has been provided
if [ -z "$1" ]; then
	echo "Please provide an SSH key as an argument."
	exit 1
fi

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

echo "Your SSH key: $1"
echo $1 | sudo tee -a /root/.ssh/authorized_keys >/dev/null

echo "SSH key has been added to /root/.ssh/authorized_keys."

echo "Restarting SSH service..."
sudo systemctl restart ssh
