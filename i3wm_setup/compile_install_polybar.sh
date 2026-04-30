#!/bin/bash

# Update system
sudo apt update
sudo apt upgrade -y

# Install dependencies
sudo apt install -y git cmake build-essential pkg-config libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libpulse-dev libssl-dev libasound2-dev libmpd-dev libcurl4-openssl-dev
sudo apt install -y build-essential git cmake cmake-data pkg-config python3-sphinx python3-packaging libuv1-dev libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev
sudo apt install -y libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev i3-wm libjsoncpp-dev libmpdclient-dev libcurl4-openssl-dev libnl-genl-3-dev

# Clone polybar repo
git clone --recursive https://github.com/polybar/polybar.git polybar_source
cd polybar_source

# Checkout to latest release
LATEST_TAG=$(curl --silent "https://api.github.com/repos/polybar/polybar/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
git checkout tags/$LATEST_TAG

# Build and install
mkdir -p build
cd build
cmake ..
make -j$(nproc)
sudo make install
