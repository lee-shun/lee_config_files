#!/bin/bash

print_error_and_exit() {
    echo -e "\n\033[0;31m命令执行错误：$1，退出状态码：$2\033[0m" >&2
    exit "$2"
}

execute_with_check() {
    local cmd="$*"
    echo "尝试执行命令: ${cmd}"
    eval "$cmd"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        print_error_and_exit "$cmd" "$exit_code"
    else
        echo -e "\033[0;32m命令执行成功: ${cmd}\033[0m"
    fi
}

example_command="ls /nonexistent_directory"
execute_with_check "$example_command"