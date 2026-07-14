#!/bin/bash
set -e

echo "=== Installing yazi (latest release) ==="

# 1. 获取最新版本号
YAZI_VERSION=$(curl -sL "https://api.github.com/repos/sxyazi/yazi/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
echo "Latest version: v${YAZI_VERSION}"

# 2. 自动判断架构
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
    x86_64)  YAZI_ARCH="x86_64" ;;
    aarch64) YAZI_ARCH="aarch64" ;;
    arm64)   YAZI_ARCH="aarch64" ;;
    *)       echo "Unsupported architecture: $RAW_ARCH"; exit 1 ;;
esac
echo "Architecture: $RAW_ARCH → $YAZI_ARCH"

# 3. 下载（优先 GNU，回退 musl）
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

for LIBC in gnu musl; do
    URL="https://github.com/sxyazi/yazi/releases/download/v${YAZI_VERSION}/yazi-${YAZI_ARCH}-unknown-linux-${LIBC}.zip"
    echo "Trying: $URL"
    if curl -fLo yazi.zip "$URL" 2>/dev/null; then
        echo "Downloaded ${LIBC} build"
        break
    fi
    if [ "$LIBC" = "musl" ]; then
        echo "Failed to download yazi for ${YAZI_ARCH}"
        exit 1
    fi
done

# 4. 解压
echo "Extracting..."
unzip -q yazi.zip

# 5. 安装 yazi 和 ya 到系统路径
sudo install yazi -D -t /usr/local/bin/
if [ -f ya ]; then
    sudo install ya -D -t /usr/local/bin/
    echo "Also installed: ya (yazi CLI)"
fi
echo "yazi installed to /usr/local/bin/yazi"

# 6. 清理
cd - >/dev/null
rm -rf "$TMP_DIR"

# 7. 验证
echo ""
yazi --version
