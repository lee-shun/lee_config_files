#!/bin/bash

download_url="https://github.com/vinceliuice/vimix-gtk-themes/archive/refs/tags/2024-04-20.tar.gz"

echo ${download_url}

# 下载最新版本的主题包
echo "Downloading the latest release of ${THEME_NAME}..."
wget -q --show-progress "$download_url" -O "vimix_theme_24_04_20.tar.gz"

# 解压并移动到主题目录
echo "Extracting and installing the theme..."
tar -xvf "vimix_theme_24_04_20.tar.gz"


echo "Installation complete."
