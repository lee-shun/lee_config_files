fzf_kill() {
  # 可选参数：关键词用于预过滤，留空则在 fzf 中自行输入
  local query="$*"

  local selected
  selected=$(ps aux --no-headers | fzf \
      --query="$query" \
      --multi \
      --header="Type to filter, Tab to select, Enter to confirm. PID in 2nd column." \
      --preview='echo {}' \
      --preview-window=up:30% | awk '{print $2}')

  if [[ -z "$selected" ]]; then
    echo "No process selected."
    return 0
  fi

  echo "The following PID(s) will be killed: $selected"
  read -p "Are you sure? (y/N) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    kill $selected
    echo "Sent SIGTERM to PID(s): $selected"
  else
    echo "Cancelled."
  fi
}
