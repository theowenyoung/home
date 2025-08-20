#!/usr/bin/env bash
set -ex

export DEBIAN_FRONTEND=noninteractive
# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y pipx

# Install Ansible
pipx install ansible

# Add Ansible to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >>~/.bashrc
fi

echo "Initial setup complete. Please update the inventory.ini file with your server's IP address."
echo "Then run the Ansible playbook with: ansible-playbook -i inventory.ini playbook.yaml"
