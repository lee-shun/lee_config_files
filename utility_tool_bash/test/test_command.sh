#!/bin/bash

# 打印错误并退出的函数
print_error_and_exit() {
    local cmd="$1"
    local exit_code=$2
    echo -e "\n\033[0;31m命令执行错误：${cmd}，退出状态码：${exit_code}\033[0m" >&2
    exit $exit_code
}

# 检查命令执行结果的函数
execute_with_check() {
    local cmd="$*"
    echo "尝试执行命令: ${cmd}"
    eval "${cmd}"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        print_error_and_exit "$cmd" $exit_code
    else
        echo -e "\033[0;32m命令执行成功: ${cmd}\033[0m"
    fi
}

# 示例命令
example_command="ls /nonexistent_directory"

# 使用函数执行命令并检查结果
execute_with_check "$example_command"
