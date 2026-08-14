#!/bin/bash

# Battery device name varies by BIOS/ACPI (BAT0, BAT1, CMB0, ...), so find it
# rather than hardcoding it.
BATTERY=$(grep -l Battery /sys/class/power_supply/*/type | head -n1 | xargs dirname)

# Read battery percentage
CAPACITY=$(cat "$BATTERY/capacity")

# Read charging status
STATUS=$(cat "$BATTERY/status")

# Determine icon based on charging/discharging state
if [[ "$STATUS" == "Charging" ]]; then
    ICON="⚡️"  # Alternative lightning bolt
elif [[ "$STATUS" == "Discharging" && "$CAPACITY" -le 20 ]]; then
    ICON="❗"  # Low battery warning (exclamation mark)
else
    ICON="🔋"  # Standard battery icon
fi

# Display battery status
echo "$ICON $CAPACITY%"

