#!/bin/bash

# Lock the screen over a pixelated, dimmed copy of the screen.
#
# With xsecurelock installed, typing brings up a password prompt in the bar's
# colours (lock-saver.py draws the background). Without it, stock i3lock is
# used with its typing ring off, since the ring can't be recoloured. Locking
# must never fail: if the image can't be made, the lock uses a plain colour.
#
# The screenshot goes straight from maim into ImageMagick; only the
# pixelated result is written, to the private runtime dir, and it's deleted
# at unlock (xsecurelock) or once loaded (i3lock).
#
# COMPOSITE_OBSCURER=0: under picom, xsecurelock's backup full-screen cover
# shows "INCOMPATIBLE COMPOSITOR, PLEASE FIX!" over the desktop as it
# unlocks. Its README gives this setting as the fix for picom.
#
# With xsecurelock this blocks until unlock, so background it when the
# caller needs to carry on (battery-alert.sh does, to suspend).

pgrep -u "$UID" -x 'i3lock|xsecurelock' >/dev/null && exit 0

dir="${XDG_RUNTIME_DIR:-/tmp}"
image="$dir/lock-screen.png"
bg="#282A2E"

make_image() {
    maim -u | convert png:- -scale 4% \
        -sample "$(xrandr | sed -nE 's/.* current ([0-9]+) x ([0-9]+),.*/\1x\2/p')!" \
        -fill '#16171A' -colorize 55% "$image"
}

make_image 2>/dev/null || rm -f "$image"

if command -v xsecurelock >/dev/null; then
    LOCK_IMAGE="$image" \
    XSECURELOCK_COMPOSITE_OBSCURER=0 \
    XSECURELOCK_SAVER="$(dirname "$(readlink -f "$0")")/lock-saver.py" \
    XSECURELOCK_BACKGROUND_COLOR="$bg" \
    XSECURELOCK_AUTH_BACKGROUND_COLOR="$bg" \
    XSECURELOCK_AUTH_FOREGROUND_COLOR="#C5C8C6" \
    XSECURELOCK_AUTH_WARNING_COLOR="#CC6666" \
    XSECURELOCK_FONT="Hack Nerd Font:size=14" \
    XSECURELOCK_PASSWORD_PROMPT=asterisks \
    XSECURELOCK_SHOW_USERNAME=0 \
    XSECURELOCK_SHOW_HOSTNAME=0 \
    XSECURELOCK_SHOW_KEYBOARD_LAYOUT=0 \
    XSECURELOCK_SHOW_DATETIME=1 \
    XSECURELOCK_DATETIME_FORMAT="%a %d %b  %H:%M" \
    XSECURELOCK_DISCARD_FIRST_KEYPRESS=0 \
    XSECURELOCK_AUTH_TIMEOUT=15 \
        xsecurelock
    rm -f "$image"
elif [ -s "$image" ]; then
    # -u: no typing ring. -e: an empty Enter isn't a failed attempt.
    # i3lock forks once the lock is up.
    i3lock -u -e -c "${bg#\#}" -i "$image"
    rm -f "$image"
else
    i3lock -u -e -c "${bg#\#}"
fi
