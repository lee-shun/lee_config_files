#!/bin/bash

find_setup_root() {
    local current_dir="${1:-.}"
    current_dir=$(cd "$current_dir" && pwd)

    while [ "$current_dir" != "/" ]; do
        if ls "$current_dir"/.{git,root,vim_root} >/dev/null 2>&1; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done

    echo "No .git directory or .root file found in the parent directories." >&2
    return 1
}

this_script=$(readlink -f "$0")
script_dir=$(dirname "$this_script")

root_dir=$(find_setup_root "$script_dir")
if [ $? -eq 0 ]; then
    echo "UBUNTU_SETUP_ROOT set to: $root_dir"
else
    echo "Failed to set UBUNTU_SETUP_ROOT."
fi