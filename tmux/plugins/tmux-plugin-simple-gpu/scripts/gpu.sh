#!/usr/bin/env bash

print_gpu_usage() {
    function getGPUUsage() {
	    gpuUsage=($(nvidia-smi -q -d UTILIZATION | grep Gpu | awk '{print $3}'))
    }
    getGPUUsage
    
    function join_by { local IFS="$1"; shift; echo "$*"; }
    gpuUsage=`join_by " " ${gpuUsage[@]}`
    if [ -z "$gpuUsage" ]; then
	printf "%-4s" "-%"
    else
	printf "%-4s" "${gpuUsage}%"
    fi
}

main() {
  print_gpu_usage
}

main
