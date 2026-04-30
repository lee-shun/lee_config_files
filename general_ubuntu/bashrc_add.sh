#!/usr/bin/env sh

######################################################################
# @author      : ShunLi (2015097272@qq.com)
# @file        : set_bashrc
# @created     : 星期二 5月 14, 2024 09:55:48 CST
#
# @description :
######################################################################

target_file="$HOME/.bashrc"

this_script=$(readlink -f "$0")
script_dir=$(dirname "$this_script")
template_file="$script_dir/bashrc.template"

# Function to check if the template content exists in the target file
template_exists_in_target() {
    local target="$1"
    local pattern="$2"

    # Check if the target file exists
    if [[ ! -f "$target" ]]; then
        echo "Target file '$target' does not exist."
        exit;
    fi

    # Check if the template content exists in the target file
    if grep -q "$pattern" "$target"; then
        return 0
    else
        return 1
    fi
}

# Function to append the content of the template file to the end of the target file
append_template_to_target() {
    local target="$1"
    local template="$2"

    cat "$template" >> "$target"
    echo "Template content appended to '$target'. you should source ~/.basrc later!"
}

# Function to create a backup of the target file if it doesn't exist
backup_target_file() {
    local target="$1"
    local backup_file="${target}.bak"

    # Check if the backup file already exists
    if [[ -f "$backup_file" ]]; then
        echo "Backup file '$backup_file' already exists."
    else
        cp "$target" "$backup_file"
        echo "Backup of '$target' created as '$backup_file'."
    fi
}

# Main script
backup_target_file "$target_file"

if template_exists_in_target "$target_file" "end of bashrc.template"; then
    echo "Template content is already present in '$target_file'."
else
    append_template_to_target "$target_file" "$template_file"
fi
