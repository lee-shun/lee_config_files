#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

target_dir="$1"

if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist."
    exit 1
fi

find "$target_dir" -type d -exec chmod 775 {} +
find "$target_dir" -type f -exec chmod 664 {} +

echo "Permissions for files and folders in directory '$target_dir' have been successfully changed."