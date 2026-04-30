#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : swapfile
# @created     : 星期四 5月 09, 2024 17:56:51 CST
#
# @description :
######################################################################

# 定义swapfile的路径和大小
SWAPFILE_PATH="$HOME/swapfile"
SWAP_SIZE=10G

# 检查swapfile是否已存在
if [ ! -f "$SWAPFILE_PATH" ]; then
    echo "Swapfile does not exist. Creating a new one..."

    # 使用dd命令创建10GB的swapfile
    sudo dd if=/dev/zero of="$SWAPFILE_PATH" bs=1G count=10

    # 设置适当的权限
    sudo chmod 600 "$SWAPFILE_PATH"

    # 将文件初始化为swap空间
    sudo mkswap "$SWAPFILE_PATH"

    # 开启swap
    sudo swapon "$SWAPFILE_PATH"

    echo "Swapfile created and activated."
else
    echo "Swapfile already exists. No action taken."
    fi

# 检查swapfile是否已经被挂载
if grep -q "$SWAPFILE_PATH" /proc/swaps; then
    echo "Swapfile is already mounted."
else
    echo "Error: Swapfile is not mounted but exists. Please check 'swapon' command output."
fi
