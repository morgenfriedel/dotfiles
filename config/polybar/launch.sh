#!/bin/bash

# Start one polybar per connected monitor: bar/main (with the tray) on the
# primary, bar/secondary everywhere else. i3 runs this on start and on every
# restart ($mod+Shift+r), so it first replaces any bars already running.

config="$HOME/.config/polybar/config.ini"
logdir="${XDG_RUNTIME_DIR:-/tmp}"

polybar-msg cmd quit >/dev/null 2>&1
# Give bars a few seconds to exit cleanly, then stop waiting and force it.
for _ in $(seq 25); do
    pgrep -u "$UID" -x polybar >/dev/null || break
    sleep 0.2
done
pkill -u "$UID" -x polybar

# Battery and adapter names vary by BIOS/ACPI (BAT0, BAT1, CMB0, AC, ADP1, ...).
# Skip scope=Device supplies: those are wireless mice and headsets, not ours.
for ps in /sys/class/power_supply/*; do
    [ "$(cat "$ps/scope" 2>/dev/null)" = "Device" ] && continue
    case "$(cat "$ps/type" 2>/dev/null)" in
        Battery) : "${POLYBAR_BATTERY:=${ps##*/}}" ;;
        Mains)   : "${POLYBAR_ADAPTER:=${ps##*/}}" ;;
    esac
done
export POLYBAR_BATTERY POLYBAR_ADAPTER

monitors=$(polybar --list-monitors)
primary=$(awk -F: '/\(primary\)/ { print $1; exit }' <<<"$monitors")
[ -n "$primary" ] || primary=$(head -n1 <<<"$monitors" | cut -d: -f1)

# Logs go to tmpfs, one file per monitor, truncated each launch, so a noisy
# warning can't grow ~/.xsession-errors without bound.
for m in $(cut -d: -f1 <<<"$monitors"); do
    bar=secondary
    [ "$m" = "$primary" ] && bar=main
    MONITOR="$m" polybar --reload --config="$config" "$bar" \
        >"$logdir/polybar-$m.log" 2>&1 &
    disown
done
