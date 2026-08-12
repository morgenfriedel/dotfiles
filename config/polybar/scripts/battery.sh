#!/bin/bash

# Read battery percentage
CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)

# Read charging status
STATUS=$(cat /sys/class/power_supply/BAT0/status)

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

