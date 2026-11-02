#!/bin/bash

# Power menu on $mod+Shift+e, shown in the launcher (launcher.sh). Log out,
# reboot and shut down ask again first, so one slip can't close every window.

dir="$(dirname "$(readlink -f "$0")")"

menu() {
    "$dir/launcher.sh" dmenu "$1"
}

confirm() {
    [ "$(printf 'No\nYes\n' | menu "$1?")" = Yes ]
}

choice=$(printf '%s\n' Lock Suspend "Log out" Reboot "Shut down" | menu power) || exit 0

case "$choice" in
    Lock)
        exec "$dir/lock.sh" ;;
    Suspend)
        # lock.sh blocks until unlock; give the lock a moment to come up
        # before the screen goes dark, as battery-alert.sh does.
        "$dir/lock.sh" &
        sleep 2
        systemctl suspend ;;
    "Log out")
        confirm "Log out" && i3-msg -q exit ;;
    Reboot)
        confirm Reboot && systemctl reboot ;;
    "Shut down")
        confirm "Shut down" && systemctl poweroff ;;
esac
