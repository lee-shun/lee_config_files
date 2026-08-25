#!/usr/bin/env bash
# net_watch.sh — 监测外网连通性，状态变化时弹通知
#
# 用法:
#   前台运行(调试):  ./net_watch.sh
#   后台运行:       setsid nohup ./net_watch.sh >/dev/null 2>&1 </dev/null &
#   停止:           pkill -f net_watch.sh
#   查看日志:       tail -f /tmp/net_watch.log
#
# 配置(环境变量):
#   NET_WATCH_INTERVAL  检测间隔秒数        (默认 30)
#   NET_WATCH_URL       测试 URL            (默认 https://www.baidu.com)
#   NET_WATCH_LOG       日志文件            (默认 /tmp/net_watch.log)
#
# 说明:
#   - 测试覆盖 DNS 解析 + TCP 443，任一不通即判定 down
#   - 状态变化时通过 notify-send 弹通知（dunst / xfce4-notifyd 均可）
#     恢复: critical 级，不自动消失；断开: normal 级，15s 消失
#   - 适合排查"路由器只通 ICMP 不通 TCP/UDP"这类故障

set -u

LOG="${NET_WATCH_LOG:-/tmp/net_watch.log}"
INTERVAL="${NET_WATCH_INTERVAL:-30}"
URL="${NET_WATCH_URL:-https://www.baidu.com}"

log() { echo "[$(date '+%F %T')] $*" >> "$LOG"; }

check() {
    timeout 12 curl -sk -o /dev/null --connect-timeout 5 --max-time 12 "$URL" 2>/dev/null
}

state=""
log "net_watch started (interval=${INTERVAL}s, url=${URL})"

while true; do
    if check; then new="up"; else new="down"; fi

    if [ -z "$state" ]; then
        log "initial state: $new"
    elif [ "$new" != "$state" ]; then
        if [ "$new" = "up" ]; then
            log "network RECOVERED"
            notify-send -u critical -a "net-watch" "外网已恢复 ✅ $(date '+%m-%d %H:%M')" 2>/dev/null
        else
            log "network LOST"
            notify-send -u normal -a "net-watch" "外网断开 ❌ $(date '+%m-%d %H:%M')" 2>/dev/null
        fi
    fi
    state="$new"
    sleep "$INTERVAL"
done
