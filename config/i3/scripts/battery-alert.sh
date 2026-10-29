#!/bin/bash

# Desktop notifications as the battery runs down. polybar only changes colour;
# this makes sure a low battery is noticed with the bar hidden behind a
# fullscreen window.
#
# Each threshold fires once per discharge and resets when the charger is
# plugged in. Notifications replace each other instead of stacking. Started
# from i3/config; the lock keeps an i3 restart from starting a second copy.

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/battery-alert.lock"
flock -n 9 || exit 0

# Highest first. Below the last one, nag every check.
thresholds=(20 10 5)
interval=60
notify_id=91000

battery=""
for ps in /sys/class/power_supply/*; do
    [ "$(cat "$ps/scope" 2>/dev/null)" = "Device" ] && continue
    if [ "$(cat "$ps/type" 2>/dev/null)" = "Battery" ]; then
        battery="$ps"
        break
    fi
done
[ -n "$battery" ] || exit 0  # desktop, nothing to watch

alerted=100  # lowest threshold already notified this discharge

while sleep "$interval"; do
    status=$(cat "$battery/status" 2>/dev/null) || continue
    capacity=$(cat "$battery/capacity" 2>/dev/null) || continue

    if [ "$status" != "Discharging" ]; then
        if [ "$alerted" -lt 100 ]; then
            dunstify -r "$notify_id" -u low -t 3000 "Battery" "Charging ($capacity%)"
            alerted=100
        fi
        continue
    fi

    # Lowest threshold the battery is at or under.
    crossed=100
    for t in "${thresholds[@]}"; do
        [ "$capacity" -le "$t" ] && crossed="$t"
    done

    if [ "$crossed" -le "${thresholds[-1]}" ]; then
        dunstify -r "$notify_id" -u critical "Battery critical: $capacity%" \
            "Plug in now — the laptop will shut down soon."
    elif [ "$crossed" -lt "$alerted" ]; then
        urgency=normal
        [ "$crossed" -le 10 ] && urgency=critical
        dunstify -r "$notify_id" -u "$urgency" "Battery low: $capacity%" \
            "Plug in soon."
    fi
    # Only ever lower it, so 20% -> 21% -> 20% doesn't alert twice.
    [ "$crossed" -lt "$alerted" ] && alerted="$crossed"
done
