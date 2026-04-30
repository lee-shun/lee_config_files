#!/bin/bash
#
# common_utils.sh - 公共工具函数
# 供 auto_scripts 中的脚本 source 使用
#

# ---------- 日志函数 ----------

log_info()    { echo -e "\e[32m[INFO]    $*\e[m"; }
log_warn()    { echo -e "\e[33m[WARNING] $*\e[m"; }
log_error()   { echo -e "\e[31m[ERROR]   $*\e[m" >&2; }
log_success() { echo -e "\e[1;32m[SUCCESS] $*\e[m"; }
log_step()    { echo -e "\e[1;35m[STEP]    $*\e[m"; }

# ---------- 权限检查 ----------

check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "此脚本需要 root 权限，请使用 sudo 运行。"
        exit 1
    fi
}

# ---------- 用户确认 ----------

confirm_action() {
    local msg="${1:-确定要继续吗？}"
    read -p "${msg} [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# ---------- 包管理 ----------

ensure_installed() {
    local pkg="$1"
    if dpkg -l "$pkg" >/dev/null 2>&1 | grep -q "^ii"; then
        log_info "已安装: $pkg"
        return 0
    fi
    log_step "安装: $pkg"
    apt install -y "$pkg" || {
        log_error "安装 $pkg 失败"
        return 1
    }
    log_success "已安装: $pkg"
}

ensure_installed_batch() {
    local packages=("$@")
    local missing=()
    for pkg in "${packages[@]}"; do
        if ! dpkg -l "$pkg" >/dev/null 2>&1 | grep -q "^ii"; then
            missing+=("$pkg")
        fi
    done
    if [ ${#missing[@]} -gt 0 ]; then
        log_step "安装 ${#missing[@]} 个缺失的包: ${missing[*]}"
        apt install -y "${missing[@]}" || {
            log_error "批量安装失败"
            return 1
        }
        log_success "批量安装完成"
    else
        log_info "所有依赖包已安装"
    fi
}

# ---------- 软链接管理 ----------

create_symlink() {
    local source="$1"
    local target="$2"
    local force="${3:-false}"

    if [ ! -e "$source" ]; then
        log_error "源路径不存在: $source"
        return 1
    fi

    if [ -L "$target" ] || [ -e "$target" ]; then
        if [ "$force" = "true" ]; then
            log_warn "目标已存在，将覆盖: $target"
            rm -f "$target"
        else
            log_warn "目标已存在: $target"
            if confirm_action "是否覆盖？"; then
                rm -f "$target"
            else
                log_info "跳过: $target"
                return 1
            fi
        fi
    fi

    ln -s "$source" "$target"
    log_success "已创建软链接: $target -> $source"
}

# ---------- Git 操作 ----------

git_clone_if_not_exists() {
    local url="$1"
    local dir="$2"
    local depth="${3:-1}"

    if [ -d "$dir/.git" ]; then
        log_info "目录已存在，跳过克隆: $dir"
        return 0
    fi

    log_step "克隆仓库: $url -> $dir"
    git clone --depth "$depth" "$url" "$dir" || {
        log_error "克隆失败: $url"
        return 1
    }
    log_success "克隆完成: $dir"
}

get_github_latest_tag() {
    local owner="$1"
    local repo="$2"
    curl --silent "https://api.github.com/repos/$owner/$repo/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"([^"]+)".*/\1/'
}

# ---------- 路径处理 ----------

get_script_dir() {
    echo "$(dirname "$(readlink -f "$0")")"
}

get_repo_root() {
    local current_dir="${1:-.}"
    current_dir=$(cd "$current_dir" && pwd)
    while [ "$current_dir" != "/" ]; do
        if [ -d "$current_dir/.git" ] || [ -f "$current_dir/.root" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done
    return 1
}
