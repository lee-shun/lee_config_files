#!/bin/bash
# 将 pi 的配置文件软链接到 ~/.pi/agent/
# 用法: bash config_pi.sh
# 说明: 从 repo 根目录创建 pi 配置软链接
# 注意: auth.json（含 API key）、sessions/、npm/ 等运行时数据不纳入管理，保留在 ~/.pi/agent/ 本地

set -euo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "$SCRIPT_DIR/../utility_tool_bash/common_utils.sh"

log_step "=========================================="
log_step "  创建 pi 配置文件软链接"
log_step "=========================================="

# 定位 repo 根目录
REPO_ROOT=$(get_repo_root "$SCRIPT_DIR")
if [ -z "$REPO_ROOT" ]; then
    log_error "无法找到 repo 根目录（未找到 .git 或 .root）"
    exit 1
fi

log_info "Repo 根目录: $REPO_ROOT"
log_info "目标目录: ~/.pi/agent/"
mkdir -p "$HOME/.pi/agent"

# 定义软链接映射: "源路径（相对 repo 根目录）" -> "目标路径"
declare -A LINKS=(
    ["pi/settings.json"]="$HOME/.pi/agent/settings.json"
    ["pi/skills"]="$HOME/.pi/agent/skills"
)

# 排序输出
LINK_NAMES=("pi/settings.json" "pi/skills")

success_count=0
skip_count=0
fail_count=0

log_info ""
for src_name in "${LINK_NAMES[@]}"; do
    src_path="$REPO_ROOT/$src_name"
    target_path="${LINKS[$src_name]}"

    if [ ! -e "$src_path" ]; then
        log_warn "源路径不存在，跳过: $src_name"
        skip_count=$((skip_count+1))
        continue
    fi

    if create_symlink "$src_path" "$target_path"; then
        success_count=$((success_count+1))
    else
        fail_count=$((fail_count+1))
    fi
done

log_info ""
log_step "------------------------------------------"
log_success "软链接创建完成"
log_info "成功: $success_count | 跳过: $skip_count | 失败: $fail_count"
log_step "------------------------------------------"
log_info ""
log_info "下一步:"
log_info "  - pi: 重启 pi 会话即可生效"
