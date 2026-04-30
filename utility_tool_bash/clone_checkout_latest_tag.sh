#!/bin/bash

checkout_latest_tag() {
    local repo_url="$1"
    local clone_dir="$2"

    if [ -d "$clone_dir" ]; then
        read -p "Directory '$clone_dir' already exists. Delete it? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$clone_dir"
        else
            echo "Aborted."
            return 1
        fi
    fi

    git clone "$repo_url" "$clone_dir" || return 1
    cd "$clone_dir" || return 1

    local latest_tag
    latest_tag=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2>/dev/null)

    if [ -z "$latest_tag" ]; then
        echo "No tags found in repository."
        return 1
    fi

    git checkout tags/"$latest_tag"
    echo "Switched to the latest tag: $latest_tag"
}

checkout_latest_tag "$@"