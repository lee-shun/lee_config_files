#!/bin/bash
set -e

echo "=== Installing lazygit (latest release) ==="

# 1. 获取最新版本号
LAZYGIT_VERSION=$(curl -sL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
echo "Latest version: v${LAZYGIT_VERSION}"

# 2. 自动判断架构
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
    x86_64)  LAZYGIT_ARCH="x86_64" ;;
    aarch64) LAZYGIT_ARCH="arm64" ;;
    arm64)   LAZYGIT_ARCH="arm64" ;;
    *)       echo "Unsupported architecture: $RAW_ARCH"; exit 1 ;;
esac
echo "Architecture: $RAW_ARCH → $LAZYGIT_ARCH"

# 3. 下载
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LAZYGIT_ARCH}.tar.gz"
echo "Downloading: $URL"
curl -Lo lazygit.tar.gz "$URL"

# 4. 解压
echo "Extracting..."
tar xf lazygit.tar.gz lazygit

# 5. 安装
sudo install lazygit -D -t /usr/local/bin/
echo "lazygit installed to /usr/local/bin/lazygit"

# 6. 清理
cd - >/dev/null
rm -rf "$TMP_DIR"

# 7. 验证
echo ""
lazygit --version

# 8. 提示
echo ""
echo "=== Usage ==="
echo "cd into any git repo and run: lazygit"
echo "Config dir: ~/.config/lazygit/"
