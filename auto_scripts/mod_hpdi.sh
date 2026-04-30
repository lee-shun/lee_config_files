#!/bin/bash
# 配置 HiDPI 显示和 Xresources
# 用法: bash mod_hpdi.sh
# 说明: 将 profile 和 Xresources 软链接到用户主目录

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

log_step "=========================================="
log_step "  配置 HiDPI 和 Xresources"
log_step "=========================================="

PROFILE_SRC="$SCRIPT_DIR/profile"
XRESOURCES_SRC="$SCRIPT_DIR/Xresources"

# ---------- 配置 .profile ----------
log_step "[1/2] 配置 .profile"
if [ -f "$PROFILE_SRC" ]; then
    log_info "源文件: $PROFILE_SRC"
    log_info "目标: $HOME/.profile"
    create_symlink "$PROFILE_SRC" "$HOME/.profile"
else
    log_warn "profile 文件不存在: $PROFILE_SRC"
    if [ -f "$HOME/.profile" ]; then
        log_info "保留现有 .profile"
    fi
fi

# ---------- 配置 .Xresources ----------
log_step "[2/2] 配置 .Xresources"
if [ -f "$XRESOURCES_SRC" ]; then
    log_info "源文件: $XRESOURCES_SRC"
    log_info "目标: $HOME/.Xresources"
    create_symlink "$XRESOURCES_SRC" "$HOME/.Xresources"

    # 尝试加载 Xresources
    if [ -n "${DISPLAY:-}" ]; then
        log_info "当前在 X 环境下，加载 Xresources..."
        if xrdb "$HOME/.Xresources" 2>/dev/null; then
            log_success "Xresources 已加载"
        else
            log_warn "xrdb 加载失败"
        fi
    else
        log_warn "不在 X 环境下（DISPLAY 未设置）"
        log_info "登录后 Xresources 将自动加载"
    fi
else
    log_warn "Xresources 文件不存在: $XRESOURCES_SRC"
    if [ -f "$HOME/.Xresources" ]; then
        log_info "保留现有 .Xresources"
    fi
fi

log_success ""
log_success "HiDPI 配置完成！"
log_info "生效方式:"
log_info "  - .profile: 重新登录"
log_info "  - .Xresources: xrdb ~/.Xresources 或重启 X 会话"
