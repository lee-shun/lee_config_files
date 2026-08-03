#!/bin/sh

icon_cpu=$(printf '')
icon_mem=$(printf '')
icon_temp=$(printf '\357\213\211')
icon_gpu=$(printf '')

cpu=$(top -bn1 | sed -n 's/^%Cpu(s):.* \([0-9.]*\) id.*/\1/p')
cpu="${cpu%.*}"
cpu=$((100 - cpu))

mem=$(free -m | awk '/^Mem:/{printf "%d", $3*100/$2}')

temp=$(sensors 2>/dev/null | awk '/Package id 0|Tctl/{print $4; exit}' | tr -d '+°C')

gpu=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk '{print $1}')

echo "${icon_cpu} ${cpu}%  ${icon_mem} ${mem}%  ${icon_temp} ${temp}°C  ${icon_gpu} ${gpu}%"
