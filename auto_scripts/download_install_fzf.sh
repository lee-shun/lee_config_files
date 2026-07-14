#!/bin/bash
set -e

echo "=== Installing fzf (latest release) ==="

# 1. 获取最新版本号
FZF_VERSION=$(curl -sL "https://api.github.com/repos/junegunn/fzf/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
echo "Latest version: v${FZF_VERSION}"

# 2. 自动判断架构
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
    x86_64)  FZF_ARCH="amd64" ;;
    aarch64) FZF_ARCH="arm64" ;;
    arm64)   FZF_ARCH="arm64" ;;
    *)       echo "Unsupported architecture: $RAW_ARCH"; exit 1 ;;
esac
echo "Architecture: $RAW_ARCH → $FZF_ARCH"

# 3. 下载并解压
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

URL="https://github.com/junegunn/fzf/releases/download/v${FZF_VERSION}/fzf-${FZF_VERSION}-linux_${FZF_ARCH}.tar.gz"
echo "Downloading: $URL"
curl -Lo fzf.tar.gz "$URL"

echo "Extracting..."
tar xf fzf.tar.gz

# 4. 安装
sudo install fzf -D -t /usr/local/bin/
echo "fzf installed to /usr/local/bin/fzf"

# 5. 清理
cd - >/dev/null
rm -rf "$TMP_DIR"

# 6. 验证
echo ""
fzf --version

# 7. 提示 shell 集成
echo ""
echo "=== Shell Integration ==="
echo "Add ONE of the following to your shell config:"
echo ""
echo "  Bash:   eval \"\$(fzf --bash)\""
echo "  Zsh:    source <(fzf --zsh)"
echo "  Fish:   fzf --fish | source"
