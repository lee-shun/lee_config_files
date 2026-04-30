#!/bin/bash

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

# Retrieve and validate the input directory argument
target_dir="$1"

# Check if the target directory exists
if [ ! -d "$target_dir" ]; then
    echo "Error: Directory '$target_dir' does not exist."
    exit 1
fi

# Recursively change folder permissions to 775
find "$target_dir" -type d -exec chmod 775 {} \;

# Recursively change file permissions to 664
find "$target_dir" -type f -exec chmod 664 {} \;

echo "Permissions for files and folders in directory '$target_dir' have been successfully changed."
