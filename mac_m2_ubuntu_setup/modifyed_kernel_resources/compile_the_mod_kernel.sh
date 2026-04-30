#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : compile_the_mod_kernel
# @created     : 星期五 5月 10, 2024 11:10:24 CST
#
# @description :
######################################################################

#!/bin/bash

find_setup_root() {
    local current_dir="$1"
    local parent_dir

    while :; do
        for target in ".git" ".root" ".vim_root"; do
            if [ -d "$current_dir/$target" ] || [ -f "$current_dir/$target" ]; then
                echo "current dir: $current_dir"
                export UBUNTU_SETUP_ROOT="$current_dir"
                return 0
            fi
        done
        # 如果已经是根目录，停止循环
        if [[ $current_dir == "/" ]]; then
            echo "No .git directory or .root file found in the parent directories." >&2
            return 1
        fi
        # 否则，继续向上查找
        parent_dir=$(dirname "$current_dir")
        if [[ $parent_dir == "$current_dir" ]]; then break; fi
        current_dir=$parent_dir
    done
}

# 获取当前脚本的绝对路径
this_script=$(readlink -f "$0")
# 获取当前脚本的目录
script_dir=$(dirname "$this_script")

find_setup_root "$script_dir"

if [[ -n $UBUNTU_SETUP_ROOT ]]; then
    echo "UBUNTU_SETUP_ROOT set to: $UBUNTU_SETUP_ROOT"
else
    echo "Failed to set UBUNTU_SETUP_ROOT."
fi
source $UBUNTU_SETUP_ROOT/utility_tool_bash/log_helper.sh

# start
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <the absolute tar.gz path> <--(no_)install>"
    exit 1
fi

COMPRESSED_SRC="$1"
IF_INSTALL="$2"
COMPILE_SOURCE=$HOME/modified_linux_asahi_build

if [ -f "/etc/sudoers_bk" ]; then
    log_info "the /etc/sudoers_bk already exists!"
else
    execute_with_check "sudo cp -r /etc/sudoers /etc/sudoers_bk"
    echo "ubuntu all=(all) nopasswd:$this_script" | sudo editor='tee -a' visudo
fi

execute_with_check "mkdir -p $COMPILE_SOURCE"
execute_with_check "cd $COMPILE_SOURCE"

# Use the [-d] test construct to check if the directory exists
if [ -d "$COMPILE_SOURCE/linux-asahi" ]; then
    echo "Directory already exists: $COMPILE_SOURCE/linux-asahi"
else
    execute_with_check "sudo tar xzvf $COMPRESSED_SRC"
fi

execute_with_check "cd linux-asahi"

# install the dependences
execute_with_check "sudo apt-get update"
execute_with_check "sudo apt-get install -y cmake g++ build-essential ncurses-dev flex bison libssl-dev libelf-dev dwarves bc procps zlib1g-dev libattr1-dev libblkid-dev libselinux-dev kmod libaio-dev libmount-dev uuid-dev"

# clean
execute_with_check "sudo make mrproper"

# copy the .config
execute_with_check "cp $script_dir/config  ./.config"

execute_with_check "make -j $(( $(nproc) - 1 ))"
execute_with_check "make modules -j $(( $(nproc) - 1 ))"

if [ "$IF_INSTALL" == "--install" ]; then
    execute_with_check "sudo make modules_install -j $(( $(nproc) - 1 ))"
    execute_with_check "sudo make -j $(( $(nproc) - 1 )) install"
    execute_with_check "sudo update-grub"
    execute_with_check "sudo update-grub2"
    log_info "you need to replace the grub file to make the new kernel takes effect!"
fi

log_info "DONE!"

exit 0;
