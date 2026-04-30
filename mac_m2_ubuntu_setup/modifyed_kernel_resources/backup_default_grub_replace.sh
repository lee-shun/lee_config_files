#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : backup_default_grub_replace
# @created     : 星期五 5月 10, 2024 10:53:28 CST
#
# @description :
######################################################################

#!/bin/bash

# Main body of the script
echo "The script is running with root privileges."
# Continue with your script logic here...

find_setup_root() {
    local current_dir="$1"
    local parent_dir

    while :; do
        for target in ".git" ".root" ".vim_root"; do
            if [ -d "$current_dir/$target" ] || [ -f "$current_dir/$target" ]; then
                echo "$current_dir"
                export UBUNTU_SETUP_ROOT="$current_dir"
                return 0
            fi
        done
        # 如果已经是根目录，停止循环
        if [[ $current_dir == "/" ]]; then
            echo "No .git directory or .root file found in the parent directories." >&2
            return 1
        fi
        # 否则，继续向上查找
        parent_dir=$(dirname "$current_dir")
        if [[ $parent_dir == "$current_dir" ]]; then break; fi
        current_dir=$parent_dir
    done
}

# 获取当前脚本的绝对路径
this_script=$(readlink -f "$0")
# 获取当前脚本的目录
script_dir=$(dirname "$this_script")

find_setup_root "$script_dir"

if [[ -n $UBUNTU_SETUP_ROOT ]]; then
    echo "UBUNTU_SETUP_ROOT set to: $UBUNTU_SETUP_ROOT"
else
    echo "Failed to set UBUNTU_SETUP_ROOT."
fi
source $UBUNTU_SETUP_ROOT/utility_tool_bash/log_helper.sh

# start
grub_bk="/etc/default/grub_bk "
if [ -f "$grub_bk" ]; then
    log_info "the $grub_bk already exists!"
else
    execute_with_check "sudo mv /etc/default/grub $grub_bk"
    execute_with_check "sudo cp -r $script_dir/grub /etc/default/grub"
fi

execute_with_check "sudo update-grub"
execute_with_check "sudo update-grub2"
log_info "you need to reboot the mac to make the grub to take effect!"

exit 0;
