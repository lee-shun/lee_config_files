#!/usr/bin/env bash
# 状态栏 GPU 使用率显示
# 优先使用 CSV 查询（跨驱动版本稳定），失败时回退到 -q 解析（兼容新老格式）

print_gpu_usage() {
    # 方法 1：CSV 查询，输出形如 "24"（多卡每行一个）
    local gpuUsage
    gpuUsage=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null)

    # 方法 2：回退，解析 -q 输出，兼容旧版 "Gpu :" 和新版 "GPU :"
    if [ -z "$gpuUsage" ]; then
        gpuUsage=$(nvidia-smi -q -d UTILIZATION 2>/dev/null \
            | awk '($1 == "GPU" || $1 == "Gpu") && $2 == ":" { print $3; exit }')
    fi

    if [ -z "$gpuUsage" ]; then
        printf "%-4s" "-%"
    else
        printf "%-4s" "$(echo "$gpuUsage" | tr '\n' ' ' | sed 's/ $//')%"
    fi
}

print_gpu_usage
