#!/bin/bash

# Brightness keys. brightnessctl writes the backlight directly when the user
# is in the `video` group (see packages/manual.md); otherwise this falls back
# to asking systemd-logind, which lets the active session set its own
# backlight without root. Never goes below 1%, so the screen can't go black.
#
#   brightness.sh up|down

step=5

# brightnessctl -m: device,class,current,percent,max
IFS=, read -r dev _ cur _ max < <(brightnessctl -m -c backlight info 2>/dev/null)
[ -n "$dev" ] || exit 0  # no backlight, e.g. a desktop

delta=$((max * step / 100))
floor=$((max / 100))
[ "$floor" -ge 1 ] || floor=1
case "$1" in
    up)   new=$((cur + delta)) ;;
    down) new=$((cur - delta)) ;;
    *)    echo "usage: ${0##*/} up|down" >&2; exit 2 ;;
esac
[ "$new" -gt "$max" ] && new=$max
[ "$new" -lt "$floor" ] && new=$floor

brightnessctl -q -d "$dev" set "$new" 2>/dev/null ||
    busctl call org.freedesktop.login1 /org/freedesktop/login1/session/auto \
        org.freedesktop.login1.Session SetBrightness ssu backlight "$dev" "$new" ||
    exit 1

pct=$((new * 100 / max))
dunstify -a brightness -u low -t 1500 \
    -h string:x-dunst-stack-tag:brightness -h "int:value:$pct" "Brightness $pct%"
