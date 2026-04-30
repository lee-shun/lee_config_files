#!/bin/bash

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : compile_install_vim9_clone_osv
# @created     : 星期四 5月 09, 2024 17:22:49 CST
#
# @description :
######################################################################


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
source $UBUNTU_SETUP_ROOT/utility_tool_bash/clone_checkout_latest_tag.sh

# download the git source code
vim_source=$HOME/vim_source
log_info $(get_cur_line_number)
execute_with_check "sudo apt install -y git  libatk1.0-dev  libcairo2-dev  libgtk-3-dev libgtk2.0-dev liblua5.1-0-dev  libncurses5-dev  libperl-dev  libx11-dev  libxpm-dev  libxt-dev  lua5.1  python3-dev  ruby-dev"

checkout_latest_tag "https://github.com/vim/vim.git" "${vim_source}"

cd $vim_source || { log_error "can not cd $vim_source!"; exit 1; }
log_info "prepare to compile the vim"
execute_with_check "./configure --with-features=huge --enable-multibyte  --enable-perlinterp  --enable-python3interp  --enable-rubyinterp --enable-luainterp --enable-tclinterp --enable-gui=gtk3 --enable-fail-if-missing"

execute_with_check "make -j $(( $(nproc) - 1 ))"
execute_with_check "sudo make -j $(( $(nproc) - 1 )) install"

execute_with_check "vim --version"
exit 0;
