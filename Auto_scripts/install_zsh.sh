#!/bin/bash
echo -e "Install the zsh and omz for you!"

sudo apt install zsh
sudo apt install git

cd ~
git clone https://github.com/lee-shun/.oh-my-zsh.git
git clone https://github.com/lee-shun/lee_config_files.git

cp -r ~/lee_config_files/.zshrc ~
