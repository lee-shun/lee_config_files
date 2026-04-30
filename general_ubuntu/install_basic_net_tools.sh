#!/bin/bash

# Update the package lists
sudo apt update

# Install the specified packages
# Using '-y' flag to automatically answer 'yes' to prompts during installation
sudo apt install -y stress gparted net-tools openssh-server openssh-client htop

# Check if the installation was successful
if [ $? -eq 0 ]; then
    echo "All packages have been installed successfully!"
else
    echo "An issue occurred during installation. Please check the error messages."
fi
