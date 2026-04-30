#!/bin/bash
# 添加 sur5r i3-gaps PPA 仓库并安装 i3 窗口管理器
# 用法: sudo bash install_i3wm_repo_apt.sh

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

check_root

log_step "=========================================="
log_step "  安装 i3-gaps 窗口管理器"
log_step "=========================================="

KEYRING_URL="https://debian.sur5r.net/i3/pool/main/s/sur5r-keyring/sur5r-keyring_2024.03.04_all.deb"
KEYRING_SHA256="f9bb4340b5ce0ded29b7e014ee9ce788006e9bbfe31e96c09b2118ab91fca734"
REPO_LIST="/etc/apt/sources.list.d/sur5r-i3.list"

# ---------- 检查是否已安装 ----------
if dpkg -l i3 >/dev/null 2>&1 | grep -q "^ii"; then
    log_warn "i3 已安装: $(dpkg -l i3 | grep '^ii' | awk '{print $3}')"
    if ! confirm_action "是否重新安装？"; then
        log_info "已取消"
        exit 0
    fi
fi

# ---------- 配置 sur5r 仓库 ----------
log_step "[1/3] 配置 sur5r i3-gaps 仓库"

if [ -f "$REPO_LIST" ]; then
    log_warn "仓库已配置: $REPO_LIST"
    if confirm_action "是否重新配置？"; then
        rm -f "$REPO_LIST"
        log_info "已删除旧配置"
    else
        log_info "跳过仓库配置"
    fi
fi

if [ ! -f "$REPO_LIST" ]; then
    log_info "下载 sur5r keyring..."
    /usr/lib/apt/apt-helper download-file \
        "$KEYRING_URL" keyring.deb "SHA256:$KEYRING_SHA256" || {
        log_error "下载 keyring 失败，请检查网络连接"
        exit 1
    }

    log_info "安装 keyring..."
    apt install -y ./keyring.deb || { log_error "安装 keyring 失败"; exit 1; }
    rm -f keyring.deb

    # 获取发行版代号
    CODENAME=$(grep '^DISTRIB_CODENAME=' /etc/lsb-release 2>/dev/null | cut -f2 -d= || true)
    if [ -z "$CODENAME" ]; then
        CODENAME=$(. /etc/os-release 2>/dev/null && echo "$VERSION_CODENAME" || true)
    fi
    if [ -z "$CODENAME" ]; then
        log_error "无法获取发行版代号"
        exit 1
    fi

    log_info "发行版代号: $CODENAME"
    echo "deb http://debian.sur5r.net/i3/ $CODENAME universe" | tee "$REPO_LIST" >/dev/null
    log_success "已添加仓库: $REPO_LIST"
fi

# ---------- 安装 i3 ----------
log_step "[2/3] 更新软件包列表"
apt update -qq

log_step "[3/3] 安装 i3-gaps"
apt install -y i3 || { log_error "安装 i3 失败"; exit 1; }

log_success "i3-gaps 安装完成！"
log_info ""
log_info "使用方法:"
log_info "  1. 注销当前会话"
log_info "  2. 在登录界面选择 'i3' 会话"
log_info "  3. 登录后 i3 将自动启动"
log_info ""
log_info "快捷键:"
log_info "  Super+Enter  - 终端"
log_info "  Super+d      - 应用启动器 (dmenu/rofi)"
log_info "  Super+q      - 关闭窗口"
log_info "  Super+1~9    - 切换工作区"
