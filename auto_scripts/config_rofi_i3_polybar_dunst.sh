#!/bin/bash
# 将 dotfiles 仓库中的配置目录软链接到 ~/.config/
# 用法: bash config_rofi_i3_polybar_dunst.sh
# 说明: 从 repo 根目录创建配置软链接

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

log_step "=========================================="
log_step "  创建配置文件软链接"
log_step "=========================================="

# 定位 repo 根目录
REPO_ROOT=$(get_repo_root "$SCRIPT_DIR")
if [ -z "$REPO_ROOT" ]; then
    log_error "无法找到 repo 根目录（未找到 .git 或 .root）"
    exit 1
fi

log_info "Repo 根目录: $REPO_ROOT"
log_info "目标目录: ~/.config/"
mkdir -p "$HOME/.config"

# 定义软链接映射: "源目录名" -> "目标路径"
declare -A LINKS=(
    ["i3"]="$HOME/.config/i3"
    ["i3blocks"]="$HOME/.config/i3blocks"
    ["i3_scripts"]="$HOME/.config/i3_scripts"
    ["polybar"]="$HOME/.config/polybar"
    ["ranger"]="$HOME/.config/ranger"
    ["rofi"]="$HOME/.config/rofi"
    ["dunst"]="$HOME/.config/dunst"
)

# 排序输出
LINK_NAMES=("dunst" "i3" "i3blocks" "i3_scripts" "polybar" "ranger" "rofi")

success_count=0
skip_count=0
fail_count=0

log_info ""
for src_name in "${LINK_NAMES[@]}"; do
    src_path="$REPO_ROOT/$src_name"
    target_path="${LINKS[$src_name]}"

    if [ ! -d "$src_path" ]; then
        log_warn "源目录不存在，跳过: $src_name"
        ((skip_count++))
        continue
    fi

    if create_symlink "$src_path" "$target_path"; then
        ((success_count++))
    else
        ((fail_count++))
    fi
done

log_info ""
log_step "------------------------------------------"
log_success "软链接创建完成"
log_info "成功: $success_count | 跳过: $skip_count | 失败: $fail_count"
log_step "------------------------------------------"
log_info ""
log_info "下一步:"
log_info "  - i3: 运行 'i3-msg restart' 或重新登录"
log_info "  - polybar: 运行 'polybar reload'"
log_info "  - rofi: 重启 rofi 即可生效"
