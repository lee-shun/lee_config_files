#!/bin/bash
# 安装 zsh 和 oh-my-zsh，配置默认 shell
# 用法: bash install_zsh_oh_my_zsh.sh

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

log_step "=========================================="
log_step "  安装 zsh + oh-my-zsh"
log_step "=========================================="

# 定位 repo 根目录
REPO_ROOT=$(get_repo_root "$SCRIPT_DIR")
if [ -z "$REPO_ROOT" ]; then
    log_error "无法找到 repo 根目录"
    exit 1
fi

OHMYZSH_SRC="$REPO_ROOT/oh-my-zsh"
ZSHRC_SRC="$SCRIPT_DIR/zshrc"

# ---------- 安装 zsh ----------
log_step "[1/4] 检查 zsh"
if command -v zsh &>/dev/null; then
    log_info "zsh 已安装: $(zsh --version)"
else
    log_warn "zsh 未安装"
    if [ "$EUID" -ne 0 ]; then
        log_error "安装 zsh 需要 root 权限，请使用 sudo 运行"
        exit 1
    fi
    log_info "正在安装 zsh..."
    apt install -y zsh || { log_error "安装 zsh 失败"; exit 1; }
    log_success "zsh 安装完成"
fi

# ---------- 安装 oh-my-zsh ----------
log_step "[2/4] 配置 oh-my-zsh"
if [ -d "$OHMYZSH_SRC" ]; then
    log_info "使用 repo 中的 oh-my-zsh"
    create_symlink "$OHMYZSH_SRC" "$HOME/.oh-my-zsh"
else
    log_warn "repo 中未找到 oh-my-zsh 目录: $OHMYZSH_SRC"
    if confirm_action "是否从官方自动安装 oh-my-zsh？"; then
        log_info "正在安装 oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
            log_error "oh-my-zsh 安装失败"
        }
    else
        log_info "跳过 oh-my-zsh 安装"
    fi
fi

# ---------- 配置 .zshrc ----------
log_step "[3/4] 配置 .zshrc"
if [ -f "$ZSHRC_SRC" ]; then
    log_info "使用 repo 中的 zshrc 配置"
    create_symlink "$ZSHRC_SRC" "$HOME/.zshrc"
else
    log_warn "未找到自定义 zshrc: $ZSHRC_SRC"
    if [ -f "$HOME/.zshrc" ]; then
        log_info "保留现有 .zshrc"
    else
        log_info "使用 oh-my-zsh 默认 .zshrc（下次启动 zsh 时自动生成）"
    fi
fi

# ---------- 设置默认 shell ----------
log_step "[4/4] 设置默认 shell"
CURRENT_SHELL="$(grep "^$USER:" /etc/passwd | cut -d: -f7)"
if [ "$CURRENT_SHELL" = "/bin/zsh" ]; then
    log_info "默认 shell 已经是 zsh"
else
    log_info "当前默认 shell: $CURRENT_SHELL"
    if confirm_action "是否将默认 shell 更改为 /bin/zsh？"; then
        if chsh -s /bin/zsh; then
            log_success "默认 shell 已更改为 zsh"
            log_info "下次登录时生效，或运行 'exec zsh' 立即切换"
        else
            log_error "更改失败，请手动运行: chsh -s /bin/zsh"
        fi
    else
        log_info "保持当前 shell 不变"
        log_info "如需临时使用 zsh，运行: zsh"
    fi
fi

log_success ""
log_success "zsh + oh-my-zsh 配置完成！"
log_info "启动 zsh: zsh"
log_info "编辑配置: nano ~/.zshrc"
