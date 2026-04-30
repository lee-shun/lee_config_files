#!/bin/bash

log_debug()   { echo -e "\e[36m[DEBUG]   $*\e[m"; }
log_info()    { echo -e "\e[32m[INFO]    $*\e[m"; }
log_warning() { echo -e "\e[33m[WARNING] $*\e[m"; }
log_error()   { echo -e "\e[31m[ERROR]   $*\e[m" >&2; }

execute_with_check() {
    local cmd="$*"
    log_info "try to execute: ${cmd}"
    eval "$cmd"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_error "error to execute: ${cmd}, exit_code: ${exit_code}"
        exit "$exit_code"
    fi
    log_info "successfully execute: ${cmd}!"
}

execute_with_check_warn() {
    local cmd="$*"
    log_info "try to execute: ${cmd}"
    eval "$cmd"
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        log_warning "warning execute: ${cmd}!"
    else
        log_info "successfully execute: ${cmd}!"
    fi
}