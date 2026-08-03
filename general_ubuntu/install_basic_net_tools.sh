#!/bin/bash

# Update the package lists
sudo apt update

# Install the specified packages
# Using '-y' flag to automatically answer 'yes' to prompts during installation
if sudo apt install -y stress gparted net-tools openssh-server openssh-client htop; then
    echo "All packages have been installed successfully!"
else
    echo "An issue occurred during installation. Please check the error messages."
fi
