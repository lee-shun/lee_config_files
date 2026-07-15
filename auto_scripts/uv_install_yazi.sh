#!/bin/bash
set -e

echo "=== Installing yazi via PyPI (yazi-bin) ==="

# 1. 检查已有安装工具
HAS_UV=$(command -v uv &>/dev/null && echo 1 || echo 0)
HAS_PIPX=$(command -v pipx &>/dev/null && echo 1 || echo 0)

# 2. 选择安装工具
if [ "$HAS_UV" -eq 1 ] && [ "$HAS_PIPX" -eq 1 ]; then
    echo "Both 'uv' and 'pipx' are available."
    read -p "Which one to use? [u]v / [p]ipx (default: uv): " choice
    case "${choice:-u}" in
        [pP]*) INSTALLER="pipx"; INSTALL_CMD="pipx install yazi-bin" ;;
        *)     INSTALLER="uv";   INSTALL_CMD="uv tool install yazi-bin" ;;
    esac

elif [ "$HAS_UV" -eq 1 ]; then
    echo "'uv' is available. 'pipx' is not found."
    read -p "Use 'uv' to install yazi? [Y/n]: " choice
    case "${choice:-Y}" in
        [yY]*) INSTALLER="uv"; INSTALL_CMD="uv tool install yazi-bin" ;;
        *) echo "Aborted."; exit 0 ;;
    esac

elif [ "$HAS_PIPX" -eq 1 ]; then
    echo "'pipx' is available. 'uv' is not found."
    read -p "Use 'pipx' to install yazi? [Y/n]: " choice
    case "${choice:-Y}" in
        [yY]*) INSTALLER="pipx"; INSTALL_CMD="pipx install yazi-bin" ;;
        *) echo "Aborted."; exit 0 ;;
    esac

else
    echo "Neither 'uv' nor 'pipx' is installed."
    echo ""
    read -p "Install [u]v / [p]ipx / [q]uit (default: uv): " choice
    case "${choice:-u}" in
        [pP]*)
            echo "Installing pipx via apt..."
            sudo apt update && sudo apt install -y pipx
            pipx ensurepath
            INSTALLER="pipx"
            INSTALL_CMD="pipx install yazi-bin"
            ;;
        [qQ]*)
            echo "Aborted."
            exit 0
            ;;
        *)
            echo "Installing uv via official install script..."
            curl -LsSf https://astral.sh/uv/install.sh | sh
            # 重新加载 PATH 以识别刚安装的 uv
            export PATH="$HOME/.local/bin:$PATH"
            INSTALLER="uv"
            INSTALL_CMD="uv tool install yazi-bin"
            ;;
    esac
fi

echo "Using installer: $INSTALLER"

# 3. 自动判断架构（信息提示）
RAW_ARCH=$(uname -m)
case "$RAW_ARCH" in
    x86_64)  YAZI_ARCH="x86_64" ;;
    aarch64) YAZI_ARCH="aarch64" ;;
    arm64)   YAZI_ARCH="aarch64" ;;
    *)       echo "Warning: architecture $RAW_ARCH may not be supported by yazi-bin" ;;
esac
echo "Architecture: $RAW_ARCH${YAZI_ARCH:+ → $YAZI_ARCH}"

# 4. 安装 yazi
echo "Running: $INSTALL_CMD"
$INSTALL_CMD

# 5. 验证
echo ""
if command -v yazi &>/dev/null; then
    yazi --version
else
    echo "yazi installed but not found in PATH."
    echo "You may need to restart your shell or add the tool bin directory to PATH."
    if [ "$INSTALLER" = "pipx" ]; then
        echo "Try: pipx ensurepath"
    elif [ "$INSTALLER" = "uv" ]; then
        echo "Try: export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
fi

# 6. 提示
echo ""
echo "=== Optional dependencies for full experience ==="
echo "  sudo apt install file fd-find ripgrep fzf zoxide jq poppler-utils imagemagick"
echo ""
echo "=== Shell integration (cd on quit) ==="
echo "Add to ~/.bashrc or ~/.zshrc:"
echo ""
echo '  function yy() {'
echo '      local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"'
echo '      yazi "$@" --cwd-file="$tmp"'
echo '      if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then'
echo '          cd -- "$cwd"'
echo '      fi'
echo '      rm -f -- "$tmp"'
echo '  }'
