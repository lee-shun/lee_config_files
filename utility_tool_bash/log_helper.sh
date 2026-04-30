#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : log_helper
# @created     : 星期四 5月 09, 2024 15:21:02 CST
#
# @description :
######################################################################

# 获取当前行号的函数
get_cur_line_number() {
    local LINENO
    LINENO=$(caller 0 | awk '{print $1}')
    echo -n "LINE: $LINENO:"
}

# 重置颜色
reset_color() {
    echo -en "\e[0m"
}

# 输出DEBUG级别日志，颜色为青色，包含行号
log_debug() {
    echo -e "\e[36m[DEBUG] $@\e[m"
    reset_color
}

# 输出INFO级别日志，颜色为绿色，包含行号
log_info() {
    echo -e "\e[32m[INFO] $@\e[m"
    reset_color
}

# 输出WARNING级别日志，颜色为黄色，包含行号
log_warning() {
    echo -e "\e[33m[WARNING] $@\e[m"
    reset_color
}

# 输出ERROR级别日志，颜色为红色，包含行号
log_error() {
    echo -e "\e[31m[ERROR] $@\e[m" >&2
    reset_color
}


# 打印错误并退出的函数
print_error_and_exit() {
    local cmd="$1"
    local exit_code=$2
    log_error "error to execute: ${cmd}, exit_code: ${exit_code}"
    exit $exit_code
}

# 检查命令执行结果的函数
execute_with_check() {
    local cmd="$*"
    log_info "try to execute: ${cmd}"
    eval "${cmd}"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        print_error_and_exit "$cmd" $exit_code
    else
        log_info "successfully execute: ${cmd}!"
    fi
}

# 检查命令执行结果的函数
execute_with_check_warn() {
    local cmd="$*"
    log_info "try to execute: ${cmd}"
    eval "${cmd}"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_warning "warning execute: ${cmd}!"
    else
        log_info "successfully execute: ${cmd}!"
    fi
}
