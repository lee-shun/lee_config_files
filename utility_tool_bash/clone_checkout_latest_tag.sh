#!/bin/bash

###############################################################################
#   Copyright (C) 2024 . All rights reserved.
#
#   @Filename: clone_checkout_latest_tag.sh
#
#   @Author: ShunLi
#
#   @Email: is.shun.li@outlook.com
#
#   @Date: 18/07/2024
#
#   @Description:
#
###############################################################################

# 函数：切换到仓库的最新标签
checkout_latest_tag() {
    local repo_url=$1
    local clone_dir=$2

    # 检查目录是否存在
    if [ -d "$clone_dir" ]; then
        # 提示用户是否删除目录
        read -p "Directory '$clone_dir' already exists. Do you want to delete it? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$clone_dir"
        else
            echo "Aborted by user."
            return 1
        fi
    fi

    # 克隆仓库
    git clone "$repo_url" "$clone_dir"

    # 切换到新克隆的目录
    cd "$clone_dir" || exit

    # 获取最新的 tag
    LATEST_TAG=$(git describe --tags $(git rev-list --tags --max-count=1))

    # 切换到最新的 tag
    git checkout tags/$LATEST_TAG

    # 输出当前所在的 tag
    echo "Switched to the latest tag: $LATEST_TAG"
}

# 示例调用
# checkout_latest_tag "https://github.com/username/reponame.git" "reponame"
