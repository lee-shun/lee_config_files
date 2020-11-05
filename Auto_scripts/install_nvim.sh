#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
END="\033[0m"

echo -e "This script will intsall nvim, lee-shun's nvim config, ranger and fzf for you!"
echo -e "$YELLOW Attention!! we can't install nvim on ARM platform, such as Nvidia TX2. $END"

#install vim or nvim
echo -e "Install nvim or vim? Input it!"
read VimType
if VimType=="nvim"
then
    sudo snap install nvim --classic
    nvim --version
else
    sudo apt install vim
    vim --version
fi

#install lee's nvim or basic vim
echo -e "Install lee's ulti or basic vim"
cd ~/.config/&&git clone https://github.com/lee-shun/nvim.git
sudo apt install xclip
sudo apt install autoconf
read InstallType
if InstallType=="ulti"
then
    #pynvim
    sudo apt install python3-pip python-pip
    pip3 install pynvim
    pip install pynvim

    #clangd
    bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
    sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-11 100

    #nodejs+npm
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    sudo apt update
    sudo apt install nodejs npm

    #fzf
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    ~/.fzf/install

    #universital-ctags
    sudo apt-get install libjansson-dev
    git clone https://github.com/universal-ctags/ctags.git --depth=1
    cd ctags
    ./autogen.sh
    ./configure
    make
    sudo make install

    #ranger
    wget https://github.com/ranger/ranger/archive/v1.9.3.zip
    unzip v1.9.3.zip
    cd ~/ranger-1.9.3/
    sudo python3 setup.py install --optimize=1 --record=install_log.txt
    cd ~/.config/
    git clone https://github.com/lee-shun/ranger.git

    #install Plugin
    echo "Entry the nvim and :Pluginstall. Press anykey..."
    read time_flag

    nvim
else
    #basic.vim
    cp ~/.config/nvim/basic.vim ~/.vimrc
fi
