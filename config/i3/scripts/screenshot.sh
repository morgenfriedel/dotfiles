#!/bin/bash

# Screenshots. Saved to ~/Pictures/Screenshots and copied to the clipboard;
# the notification shows a preview. Esc while selecting cancels and saves
# nothing.
#
#   screenshot.sh          whole screen (Print)
#   screenshot.sh select   drag a region or click a window ($mod+Print)

dir="$HOME/Pictures/Screenshots"
file="$dir/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
mkdir -p "$dir"

case "$1" in
    select) maim -s "$file" ;;
    *)      maim "$file" ;;
esac || { rm -f "$file"; exit 0; }

xclip -selection clipboard -t image/png -i "$file"
dunstify -a screenshot -u low -i "$file" "Screenshot taken" "${file/#$HOME/\~}"
