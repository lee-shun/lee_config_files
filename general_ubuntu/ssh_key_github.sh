#!/bin/bash

# Prompt user for their GitHub email (replace with actual prompt as needed)
read -rp "Enter your GitHub email: " email
read -rp "Enter a key name (default is id_rsa): " key_name
key_name=${key_name:-id_rsa}

# Check if the SSH key pair exists, generate a new one if not
if [ ! -f ~/.ssh/"$key_name" ]; then
    echo "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -C "$email" -f ~/.ssh/"$key_name" -N ""
    echo "SSH key pair generated."
else
    echo "SSH key pair already exists."
fi

# Start ssh-agent and add the private key
eval "$(ssh-agent -s)"
if ssh-add ~/.ssh/"$key_name"; then
    echo "Private key added to ssh-agent."
else
    echo "Failed to add private key to ssh-agent, please handle manually."
fi

# Copy public key to clipboard (requires xclip tool)
if command -v xclip > /dev/null 2>&1; then
    xclip -selection clipboard < ~/.ssh/"$key_name".pub
    echo "Public key copied to clipboard."
else
    cat ~/.ssh/"$key_name".pub
    echo "Warning: xclip not found, unable to automatically copy public key to clipboard. Please manually copy the content of ~/.ssh/$key_name.pub."
fi

echo "Next, log in to your GitHub account, navigate to Settings -> SSH and GPG keys -> New SSH key, paste the public key, and save it."

# Notify the user to manually complete the SSH key addition on GitHub
read -rp "Press Enter to continue and test the SSH connection..."

# Test the SSH connection
if ssh -T git@github.com 2>&1 | grep -q 'Hi'; then
    echo "SSH key configuration successful, successfully connected to GitHub."
else
    echo "There might be an issue with the SSH key configuration, please check your settings."
fi
