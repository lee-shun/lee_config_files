# ROS2
source /opt/ros/humble/setup.bash

export ROS2_WORKSPACES=(
    "$HOME/ros2_ws"
    "$HOME/fpv_ws"
)

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
    local packages=()
    for ws in "${ROS2_WORKSPACES[@]}"; do
        if [ -d "$ws/src" ]; then
            while IFS= read -r pkg_dir; do
                local pkg_name=$(basename "$pkg_dir")
                packages+=("$ws/src/$pkg_name")
            done < <(find "$ws/src" -maxdepth 2 -name "CMakeLists.txt" -path "*/src/*/CMakeLists.txt" -exec dirname {} \; 2>/dev/null)
        fi
    done

    if [ ${#packages[@]} -eq 0 ]; then
        echo "No ROS2 packages found in the specified workspaces."
        return 1
    fi

    local selected=$(printf '%s\n' "${packages[@]}" | fzf --multi --preview "echo {}" --preview-window down:50%)
    if [ -n "$selected" ]; then
        while IFS= read -r path; do
            cd "$path" || return 1
        done <<< "$selected"
    fi
}
