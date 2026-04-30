#!/bin/bash
# 从源码编译安装 picom 合成器 (yshui 分支)
# 用法: sudo bash compile_install_picom.sh

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

check_root

log_step "=========================================="
log_step "  从源码编译安装 picom"
log_step "=========================================="

BUILD_DIR="/tmp/picom_build"
REPO_URL="https://github.com/yshui/picom.git"

# ---------- 更新系统 ----------
log_step "[1/4] 更新系统软件包"
apt update -qq
apt upgrade -y -qq

# ---------- 安装编译依赖 ----------
log_step "[2/4] 检查并安装编译依赖"
ensure_installed_batch \
    git meson ninja-build \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev \
    libxcb-randr0-dev libxcb-render0-dev libxcb-render-util0-dev \
    libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev \
    uthash-dev

# ---------- 克隆源码 ----------
log_step "[3/4] 获取 picom 源码"
if [ -d "$BUILD_DIR/.git" ]; then
    log_warn "构建目录已存在: $BUILD_DIR"
    if confirm_action "是否删除并重新克隆？"; then
        rm -rf "$BUILD_DIR"
    else
        log_info "使用现有目录"
    fi
fi

git_clone_if_not_exists "$REPO_URL" "$BUILD_DIR"

# ---------- 编译安装 ----------
log_step "[4/4] 编译并安装 picom"
cd "$BUILD_DIR"

log_info "配置 Meson 构建系统..."
meson setup build || { log_error "Meson 配置失败"; exit 1; }

log_info "开始编译 (使用 $(nproc) 线程)..."
ninja -C build || { log_error "编译失败"; exit 1; }

log_info "安装到系统..."
ninja -C build install || { log_error "安装失败"; exit 1; }

# ---------- 清理 ----------
log_info "清理构建目录..."
rm -rf "$BUILD_DIR"

log_success "picom 编译安装完成！"
if command -v picom &>/dev/null; then
    log_info "版本: $(picom --version 2>&1 | head -1)"
else
    log_warn "无法验证 picom 版本，请检查 PATH"
fi
log_info "配置 picom: 将 compton.conf 或 picom.conf 放到 ~/.config/picom.conf"
