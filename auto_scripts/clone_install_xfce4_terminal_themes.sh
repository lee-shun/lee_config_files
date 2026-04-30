#!/bin/bash
# 从 GitHub 克隆 xfce4-terminal 主题并安装
# 用法: bash clone_install_xfce4_terminal_themes.sh
# 说明: 不需要 sudo，主题安装到用户目录

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

log_step "=========================================="
log_step "  安装 xfce4-terminal 主题"
log_step "=========================================="

TARGET_DIR="$HOME/.local/share/xfce4/terminal"
REPO_URL="https://github.com/ianriva/xfce4-terminal-themes.git"

log_info "目标目录: $TARGET_DIR"
log_info "仓库地址: $REPO_URL"

if [ -d "$TARGET_DIR/.git" ]; then
    log_warn "目标目录已存在，可能已安装"
    if confirm_action "是否删除旧版本并重新安装？"; then
        log_info "删除旧版本..."
        rm -rf "$TARGET_DIR"
    else
        log_info "已取消"
        exit 0
    fi
fi

mkdir -p "$(dirname "$TARGET_DIR")"
git_clone_if_not_exists "$REPO_URL" "$TARGET_DIR"

log_success "xfce4-terminal 主题安装完成！"
log_info "主题位置: $TARGET_DIR"
log_info "重启 xfce4-terminal 后在 Theme 设置中选择主题"
