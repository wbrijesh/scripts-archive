#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: $0 <ADMIN_KEYS>"
	exit 1
fi

ADMIN_KEYS=$1

sudo apt update
sudo apt install -y snapd nginx neovim btop neofetch
sudo snap install --dangerous --classic go
sudo snap install --dangerous --classic certbot

# Create TLS certificate for domain
sudo /snap/bin/certbot certonly --standalone

# Create directory for keyrings
sudo mkdir -p /etc/apt/keyrings

# Download GPG key and save to keyring directory
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg

# Add repository to sources list
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list

# Update package lists and install required packages
sudo apt update && sudo apt install -y soft-serve git

# Create empty soft-serve service file
sudo touch /etc/systemd/system/soft-serve.service

# Download and insert contents into the soft-serve service file
sudo curl -fsSL https://raw.githubusercontent.com/wbrijesh/scripts/main/static/git/soft-serve-systemd-service.txt -o /etc/systemd/system/soft-serve.service

# Replace placeholder with provided ADMIN_KEYS
sudo sed -i "s/Environment=SOFT_SERVE_INITIAL_ADMIN_KEYS='ssh-ed25519 AAAAC3NzaC1lZDI1...'/Environment=SOFT_SERVE_INITIAL_ADMIN_KEYS='$ADMIN_KEYS'/g" /etc/systemd/system/soft-serve.service

# Enable the Systemd service
sudo systemctl daemon-reload
sudo systemctl enable soft-serve.service
sudo systemctl start soft-serve.service
sudo systemctl stop soft-serve.service

# Check if the file exists
if [ ! -f "/var/local/lib/soft-serve/config.yaml" ]; then
	echo "Config file not found!"
	exit 1
fi

# Replace 'listen_addr' line
sudo sed -i 's/listen_addr: ":23231"/listen_addr: ":22"/g' /var/local/lib/soft-serve/config.yaml

# Replace 'public_url' line
sudo sed -i 's/public_url: "ssh:\/\/localhost:23231"/public_url: "ssh:\/\/brijesh.dev"/g' /var/local/lib/soft-serve/config.yaml

sudo sed -i 's/^#Port 22/Port 2200/g' /etc/ssh/sshd_config
sudo systemctl restart sshd

sudo systemctl start soft-serve.service

sudo reboot now
