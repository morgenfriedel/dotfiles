#!/bin/bash

# Desktop notifications as the battery runs down, and suspend before it dies.
# polybar only changes colour; this makes sure a low battery is noticed with
# the bar hidden behind a fullscreen window.
#
# Each threshold fires once per discharge and resets when the charger is
# plugged in. Notifications replace each other instead of stacking. Started
# from i3/config; the lock keeps an i3 restart from starting a second copy.
#
# At $suspend_at% on battery it warns, waits $grace seconds, then locks the
# screen and suspends. Plugging in cancels; clicking or dismissing the warning
# cancels auto-suspend for the rest of this discharge.
#
# BATTERY_ALERT_TEST=1 runs a separate instance that checks every 5s, treats
# any charge as low enough to suspend, and only notifies instead of locking
# and suspending.

# Highest first. Below the last one, nag every check.
thresholds=(20 10 5)
interval=60
suspend_at=3
grace=60
notify_id=91000
suspend_id=91001
lock="${XDG_RUNTIME_DIR:-/tmp}/battery-alert.lock"
test_mode=0

if [ "${BATTERY_ALERT_TEST:-0}" = 1 ]; then
    test_mode=1
    interval=5
    suspend_at=100
    grace=15
    lock="${lock%.lock}-test.lock"
fi

exec 9>"$lock"
flock -n 9 || exit 0

battery=""
for ps in /sys/class/power_supply/*; do
    [ "$(cat "$ps/scope" 2>/dev/null)" = "Device" ] && continue
    if [ "$(cat "$ps/type" 2>/dev/null)" = "Battery" ]; then
        battery="$ps"
        break
    fi
done
[ -n "$battery" ] || exit 0  # desktop, nothing to watch

# dunst's do-not-disturb would hold critical notifications until it's
# switched off; dunst 1.9 can't exempt them, so switch it off.
end_dnd() {
    if [ "$(dunstctl is-paused)" = "true" ]; then
        dunstctl set-paused false
        polybar-msg action dnd hook 0 >/dev/null 2>&1
    fi
}

# Warn, then lock and suspend unless the charger is plugged in or the user
# cancels within $grace seconds. Returns 1 if the user cancelled.
suspend_soon() {
    local pid waited=0
    end_dnd
    # With an action, dunstify blocks until the notification is clicked or
    # closed, so it runs in the background while this polls the charger.
    dunstify -r "$suspend_id" -u critical -A "default,Cancel" \
        "Battery at $capacity% — suspending in ${grace}s" \
        "Plug in, or click to keep running on battery." >/dev/null 9>&- &
    pid=$!

    while [ "$waited" -lt "$grace" ]; do
        sleep 5 9>&-
        waited=$((waited + 5))
        if [ "$(cat "$battery/status" 2>/dev/null)" != "Discharging" ]; then
            kill "$pid" 2>/dev/null
            dunstify -C "$suspend_id"
            return 0
        fi
        if ! kill -0 "$pid" 2>/dev/null; then
            dunstify -r "$suspend_id" -u normal "Auto-suspend cancelled" \
                "It won't suspend again until the next time you unplug."
            return 1
        fi
    done

    kill "$pid" 2>/dev/null
    dunstify -C "$suspend_id"

    if [ "$test_mode" = 1 ]; then
        dunstify -r "$suspend_id" -u low "battery-alert test" "Would lock and suspend now."
        return 0
    fi
    # lock.sh blocks until unlock when xsecurelock is installed, so it runs in
    # the background; the pause lets the lock come up before the screen goes
    # dark, so waking never flashes the desktop.
    "$(dirname "$0")/lock.sh" 9>&- &
    sleep 2 9>&-
    systemctl suspend
}

alerted=100        # lowest threshold already notified this discharge
suspend_skipped=0  # user cancelled auto-suspend this discharge

# 9>&-: children must not inherit the lock, or a killed instance's orphaned
# sleep would keep a restart locked out for up to $interval.
while sleep "$interval" 9>&-; do
    status=$(cat "$battery/status" 2>/dev/null) || continue
    capacity=$(cat "$battery/capacity" 2>/dev/null) || continue

    if [ "$status" != "Discharging" ]; then
        if [ "$alerted" -lt 100 ]; then
            dunstify -r "$notify_id" -u low -t 3000 "Battery" "Charging ($capacity%)"
            alerted=100
        fi
        suspend_skipped=0
        continue
    fi

    if [ "$capacity" -le "$suspend_at" ] && [ "$suspend_skipped" = 0 ]; then
        suspend_soon || suspend_skipped=1
        continue
    fi

    # Lowest threshold the battery is at or under.
    crossed=100
    for t in "${thresholds[@]}"; do
        [ "$capacity" -le "$t" ] && crossed="$t"
    done

    if [ "$crossed" -le "${thresholds[-1]}" ]; then
        end_dnd
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
