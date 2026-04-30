#!/bin/bash
# 从源码编译安装 polybar 状态栏
# 用法: sudo bash compile_install_polybar.sh

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

check_root

log_step "=========================================="
log_step "  从源码编译安装 polybar"
log_step "=========================================="

BUILD_DIR="/tmp/polybar_build"
REPO_URL="https://github.com/polybar/polybar.git"

# ---------- 更新系统 ----------
log_step "[1/4] 更新系统软件包"
apt update -qq
apt upgrade -y -qq

# ---------- 安装编译依赖 ----------
log_step "[2/4] 检查并安装编译依赖"
ensure_installed_batch \
    git cmake build-essential pkg-config \
    libx11-dev libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev \
    libpulse-dev libssl-dev libasound2-dev libmpd-dev libcurl4-openssl-dev \
    cmake-data python3-sphinx python3-packaging libuv1-dev \
    libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev \
    libxcb-composite0-dev python3-xcbgen xcb-proto \
    libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev \
    libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev \
    libjsoncpp-dev libmpdclient-dev libnl-genl-3-dev

# ---------- 获取最新 tag ----------
log_step "[3/4] 获取 polybar 源码"
LATEST_TAG=$(get_github_latest_tag "polybar" "polybar" 2>/dev/null || true)
if [ -n "$LATEST_TAG" ]; then
    log_info "最新 release: $LATEST_TAG"
else
    log_warn "无法获取最新 tag，将使用 master 分支"
fi

if [ -d "$BUILD_DIR/.git" ]; then
    log_warn "构建目录已存在: $BUILD_DIR"
    if confirm_action "是否删除并重新克隆？"; then
        rm -rf "$BUILD_DIR"
    else
        cd "$BUILD_DIR"
        log_info "更新现有仓库..."
        git fetch --all
        if [ -n "$LATEST_TAG" ]; then
            git checkout "$LATEST_TAG"
        fi
        git submodule update --init --recursive
    fi
else
    git clone --recursive "$REPO_URL" "$BUILD_DIR"
    if [ -n "$LATEST_TAG" ]; then
        cd "$BUILD_DIR"
        git checkout "$LATEST_TAG"
        log_info "切换到 tag: $LATEST_TAG"
    fi
fi

# ---------- 编译安装 ----------
log_step "[4/4] 编译并安装 polybar"
cd "$BUILD_DIR"

mkdir -p build && cd build

log_info "配置 CMake..."
cmake .. || { log_error "CMake 配置失败"; exit 1; }

log_info "开始编译 (使用 $(nproc) 线程)..."
make -j"$(nproc)" || { log_error "编译失败"; exit 1; }

log_info "安装到系统..."
make install || { log_error "安装失败"; exit 1; }

# ---------- 清理 ----------
log_info "清理构建目录..."
rm -rf "$BUILD_DIR"

log_success "polybar 编译安装完成！"
if command -v polybar &>/dev/null; then
    log_info "版本: $(polybar --version 2>&1 | head -1)"
else
    log_warn "无法验证 polybar 版本，请检查 PATH"
fi
log_info "配置 polybar: 将配置放到 ~/.config/polybar/config"
log_info "启动 polybar: polybar mybar"
