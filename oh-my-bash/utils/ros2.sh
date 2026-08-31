# ROS2
#
# Workspaces: define ROS2_WORKSPACES in .bashrc (before utils/*.sh are sourced)
# to control which workspaces are sourced and searched:
#   export ROS2_WORKSPACES=("$HOME/fpv_ws" "$HOME/ros2_ws")
# If not defined, falls back to the defaults below. Missing workspaces are
# skipped automatically.

if [ -z "${ROS2_WORKSPACES[*]:-}" ]; then
    ROS2_WORKSPACES=(
        "$HOME/ros2_ws"
        "$HOME/fpv_ws"
    )
fi

# Source ROS distro (default: humble, override with ROS_DISTRO)
ROS_DISTRO="${ROS_DISTRO:-humble}"
if [ -f "/opt/ros/$ROS_DISTRO/setup.bash" ]; then
    source "/opt/ros/$ROS_DISTRO/setup.bash"
fi

# Source each workspace's install/setup.bash
for ws in "${ROS2_WORKSPACES[@]}"; do
    if [ -f "$ws/install/setup.bash" ]; then
        source "$ws/install/setup.bash"
    fi
done

colcon() {
    # A wrapper for `colcon build`
    # If the first argument is "build", check the current directory
    if [[ "$1" == "build" ]]; then
        local valid_ws=false
        for ws in "${ROS2_WORKSPACES[@]}"; do
            if [ "$PWD" == "$ws" ]; then
                valid_ws=true
                break
            fi
        done
        if [ "$valid_ws" != "true" ]; then
            echo "Error: 'colcon build' must be run from one of the configured workspaces."
            return 1
        fi
    fi
    # Execute the actual colcon command with all provided arguments
    command colcon "$@"
}

ros2cd() {
    # Jump to a ROS2 package via fzf.
    # Usage: ros2cd [workspace_name_prefix]
    #   workspace_name_prefix: optional, only search workspaces whose name
    #                          starts with this (e.g. "ros2cd fpv")
    command -v fzf >/dev/null 2>&1 || { echo "ros2cd: fzf is required"; return 1; }

    local filter="${1:-}"
    local packages=() ws ws_name pkg_xml rel

    for ws in "${ROS2_WORKSPACES[@]}"; do
        [ -d "$ws/src" ] || continue
        ws_name=$(basename "$ws")
        if [ -n "$filter" ] && [[ "$ws_name" != "$filter"* ]]; then
            continue
        fi
        # package.xml is the canonical ROS2 package marker: covers CMake and
        # ament_python packages, including ones nested one level deeper
        while IFS= read -r pkg_xml; do
            rel="${pkg_xml#"$ws/src/"}"
            rel="${rel%/*}"
            packages+=("$ws_name/$rel"$'\t'"$ws/src/$rel")
        done < <(find "$ws/src" -maxdepth 3 -name "package.xml" 2>/dev/null | sort)
    done

    if [ ${#packages[@]} -eq 0 ]; then
        echo "No ROS2 packages found in workspaces: ${ROS2_WORKSPACES[*]}"
        return 1
    fi

    local selected
    selected=$(printf '%s\n' "${packages[@]}" | fzf --multi \
        --preview='dir=$(cut -f2 <<< "{}"); if [ -f "$dir/package.xml" ]; then echo "=== package.xml ==="; cat "$dir/package.xml"; else for f in README.md README.rst README; do [ -f "$dir/$f" ] && { echo "=== $f ==="; cat "$dir/$f"; exit 0; }; done; echo "(no package.xml/README in $dir)"; fi' \
        --preview-window=down:50%)
    if [ -n "$selected" ]; then
        # cd into the last selected package
        local target
        target=$(printf '%s\n' "$selected" | tail -1 | cut -f2)
        cd "$target" || return 1
    fi
}
