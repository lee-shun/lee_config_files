#!/bin/sh
# 给 tmux 设定「本机桌面」的 X display。
#
# 为什么需要：tmux 服务端如果在 `ssh -X` 会话里启动过，它的全局环境会固化一个
# 转发用的 DISPLAY（形如 localhost:10.0）。ssh 一断，这个值就没人监听了，但它会
# 继续被继承给新建的 pane —— 结果 pane 里所有走 X 的剪贴板工具（xclip / xsel）
# 全部静默失败：nvim 报 "clipboard: error invoking xclip"，tmux copy-mode 的
# copy-pipe 'xclip -se c -i' 也复制不出东西。
#
# 做法：优先取当前已登录的本机图形会话（who 的 :N），其次退回任意本机 X socket。
# 只在有本机 X 时设置；远程 attach（无本机显示）场景交给 OSC52 通道。
set -u

d=$(who 2>/dev/null | awk '$2 ~ "^:[0-9]+$" { sub(":", "", $2); print $2; exit }')

if [ -z "$d" ]; then
    for s in /tmp/.X11-unix/X*; do
        [ -S "$s" ] || continue
        d=${s##*/X}
        break
    done
fi

[ -n "${d:-}" ] || exit 0
tmux set-environment -g DISPLAY ":$d"
# 已有 session 各自持有环境副本（新建 session 还会从发起方继承 DISPLAY），
# 所以逐个覆盖，避免旧 session 继续把坏值传给新 pane。
for s in $(tmux list-sessions -F '#S' 2>/dev/null); do
    tmux set-environment -t "$s" DISPLAY ":$d"
done
