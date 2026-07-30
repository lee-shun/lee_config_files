#!/usr/bin/env bash

options="⏻ Shutdown\n Reboot\n Suspend\n Lock\n Logout"

selected=$(echo -e "$options" | rofi -dmenu -p "Power" -theme-str 'window {width: 200;} listview {lines: 5;}')

case "$selected" in
    *Shutdown) systemctl poweroff ;;
    *Reboot)   systemctl reboot ;;
    *Suspend)  systemctl suspend ;;
    *Lock)     slock ;;
    *Logout)   i3-msg exit ;;
esac
