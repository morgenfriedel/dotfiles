#!/bin/bash

# Volume and mic keys. Uses pactl, which works with PulseAudio and with
# PipeWire's pulse layer alike, and shows the result in a single dunst popup
# that each press replaces instead of stacking.
#
#   volume.sh up|down|mute|mic-mute

step=5
max=100  # keys never push past this; pavucontrol still can

sink_volume() {
    pactl get-sink-volume @DEFAULT_SINK@ | grep -oE '[0-9]+%' | head -n1 | tr -d %
}

popup() {
    dunstify -a volume -u low -t 1500 \
        -h string:x-dunst-stack-tag:volume "$@"
}

case "$1" in
    up)
        pactl set-sink-mute @DEFAULT_SINK@ 0
        vol=$(sink_volume)
        if [ "$vol" -lt "$max" ]; then
            new=$((vol + step))
            [ "$new" -gt "$max" ] && new=$max
            pactl set-sink-volume @DEFAULT_SINK@ "$new%"
        fi
        ;;
    down)
        pactl set-sink-volume @DEFAULT_SINK@ "-$step%"
        ;;
    mute)
        pactl set-sink-mute @DEFAULT_SINK@ toggle
        ;;
    mic-mute)
        pactl set-source-mute @DEFAULT_SOURCE@ toggle
        if pactl get-source-mute @DEFAULT_SOURCE@ | grep -q yes; then
            popup "Microphone muted"
        else
            popup "Microphone on"
        fi
        exit 0
        ;;
    *)
        echo "usage: ${0##*/} up|down|mute|mic-mute" >&2
        exit 2
        ;;
esac

if pactl get-sink-mute @DEFAULT_SINK@ | grep -q yes; then
    popup "Muted"
else
    vol=$(sink_volume)
    popup -h "int:value:$vol" "Volume $vol%"
fi
