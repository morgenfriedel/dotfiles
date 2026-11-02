#!/bin/bash

# rofi inside polybar, over the window title: from just right of the "|"
# separator up to the metrics (config/rofi/config.rasi). bar-gap.py measures
# that each time, so the field fits however many workspaces there are; if it
# can't, the theme's fixed position is used. Falls back to dmenu without rofi.
#
#   launcher.sh apps             $mod+d: apps; Ctrl+Tab for commands, windows
#   launcher.sh windows          $mod+w: jump to any open window
#   launcher.sh dmenu PROMPT     pick one line from stdin, in a row
#   launcher.sh list PROMPT      same, as a list dropping down from the bar

dmenu_args=(-b -i -fn "Hack Nerd Font Mono:style=Regular:size=11"
            -nb "#282A2E" -nf "#C5C8C6" -sb "#F2CC83" -sf "#282A2E")

# A list that drops down below the field instead of a row inside it.
list_theme='
    mainbox  { orientation: vertical; children: [ inputbar, listview ]; padding: 0 0 6px; }
    inputbar { children: [ prompt, entry ]; padding: 0 6px 0 10px; }
    entry    { expand: true; }
    listview { layout: vertical; lines: 12; fixed-height: false; }
    element  { padding: 4px 10px; border: 0 0 0 2px; }
'

if ! command -v rofi >/dev/null; then
    case "$1" in
        apps)    exec dmenu_run "${dmenu_args[@]}" ;;
        windows) exit 0 ;;  # dmenu has no window switcher
        *)       exec dmenu "${dmenu_args[@]}" -p "$2" ;;
    esac
fi

theme=""
place=()
if read -r output x width < <("$(dirname "$(readlink -f "$0")")/bar-gap.py") && [ -n "$width" ]; then
    place=(-m "$output")
    theme="window { location: northwest; anchor: northwest; x-offset: ${x}px; width: ${width}px; }"
fi

case "$1" in
    apps)    rofi "${place[@]}" -show drun -theme-str "$theme" ;;
    windows) rofi "${place[@]}" -show window -theme-str "$theme $list_theme" ;;
    dmenu)   rofi "${place[@]}" -dmenu -i -p "$2" -theme-str "$theme" ;;
    list)    rofi "${place[@]}" -dmenu -i -p "$2" -theme-str "$theme $list_theme" ;;
esac
