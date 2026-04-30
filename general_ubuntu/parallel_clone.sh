#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : parallel_clone
# @created     : 星期四 5月 09, 2024 18:06:01 CST
#
# @description :
######################################################################

# 仓库列表
user_name="shun-li-casia"
REPOS=("image_algorithm" "image_imu_post_processor" "image_imu_file_processor" "utility_tool" "sensor_config")

# 询问用户选择克隆协议
echo "choose the protocol(HTTPS/SSH):"
select protocol in "HTTPS" "SSH"; do
  case $protocol in
    HTTPS|SSH)
      break
      ;;
    *)
      echo "Invalid option, please choose again."
      ;;
  esac
done

# 根据用户选择设置URL前缀
if [ "$protocol" = "HTTPS" ]; then
  url_prefix="https://github.com/$user_name/"
elif [ "$protocol" = "SSH" ]; then
  url_prefix="git@github.com:$user_name/"
fi

read -p "Enter a path (default is current): " clone_path
clone_path=${clone_path:-$(pwd)}

# 克隆函数
clone_repo() {
    local repo=$1
    local retry_count=0
    local max_retries=3

    until git clone $url_prefix$repo $clone_path/$repo; do
        if (( retry_count < max_retries )); then
            echo "Clone of $repo_url failed, retrying ($((retry_count + 1)) of $max_retries)..."
            ((retry_count++))
        else
            echo "Failed to clone $repo_url after $max_retries retries. Aborting."
            exit 1
        fi
    done
    echo "$repo_url cloned successfully."
}

# 并行克隆
for repo in "${REPOS[@]}"; do
    clone_repo "$repo" &
done

# 等待所有后台任务完成
wait

echo "All repositories have been cloned successfully."
