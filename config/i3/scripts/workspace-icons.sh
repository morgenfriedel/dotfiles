#!/bin/bash

# Rename each i3 workspace to "N:<icons>", one icon per distinct app on it,
# and back to plain "N" when it empties. polybar's strip-wsnumbers then shows
# just the icons (or the number, for an empty workspace).
#
# Event-driven: it sleeps on i3's IPC socket and only rebuilds when a window
# opens, closes or moves — not on focus or title changes, which are constant.
# Keybindings must use `workspace number N`, since names no longer equal "N".
# If this isn't running, workspaces are just numbers again.
#
# Started once from i3/config. It reconnects across `i3 restart` and exits
# with i3; the lock keeps a second copy from starting.

exec 9>"${XDG_RUNTIME_DIR:-/tmp}/workspace-icons.lock"
flock -n 9 || exit 0

if ! command -v jq >/dev/null; then
    dunstify -u normal "workspace-icons" "jq is not installed; workspaces will show plain numbers."
    exit 1
fi

# Matched against the lowercased WM_CLASS class (`xprop WM_CLASS`, second
# string). Icons are Hack Nerd Font glyphs.
# Sets REPLY rather than echoing, so a rebuild forks no subshells.
icon_for() {
    case "$1" in
        st|kitty|alacritty|xterm*)        REPLY="" ;;
        firefox*)                         REPLY="" ;;
        google-chrome*|chromium*)         REPLY="" ;;
        qutebrowser|falkon)               REPLY="" ;;
        code|code-oss|jetbrains-*)        REPLY="" ;;
        slack)                            REPLY="" ;;
        zoom*)                            REPLY="" ;;
        spotify)                          REPLY="" ;;
        vlc|mpv)                          REPLY="" ;;
        obsidian)                         REPLY="" ;;
        typora)                           REPLY="" ;;
        dbeaver|tableplus)                REPLY="" ;;
        thunar|pcmanfm|nautilus)          REPLY="" ;;
        gimp*)                            REPLY="" ;;
        libreoffice*|soffice|xpdf*)       REPLY="" ;;
        galculator)                       REPLY="" ;;
        pavucontrol)                      REPLY="" ;;
        virt-manager)                     REPLY="" ;;
        *)                                REPLY="" ;;
    esac
}

update() {
    local tree renames="" num name classes icons class icon new
    tree=$(i3-msg -t get_tree) || return

    # One line per real workspace (skips the scratchpad): num, name, classes.
    while IFS=$'\t' read -r num name classes; do
        icons=""
        for class in $classes; do
            icon_for "$class"; icon=$REPLY
            [[ "$icons" == *"$icon"* ]] || icons+="${icons:+ }$icon"
        done
        new="$num"
        [ -n "$icons" ] && new="$num:$icons"
        [ "$new" = "$name" ] && continue
        renames+="rename workspace \"${name//\"/\\\"}\" to \"$new\"; "
    done < <(jq -r '
        .. | objects | select(.type == "workspace" and .num >= 0)
        | [ .num, .name,
            ([ .. | objects | .window_properties?.class // empty
               | ascii_downcase | gsub("\\s"; "_") ] | join(" ")) ]
        | @tsv' <<<"$tree")

    [ -n "$renames" ] && i3-msg -q "$renames"
}

# `i3 restart` drops the IPC connection; reconnect, backing off, and give up
# once i3 has been unreachable for a while (it exited).
failures=0
while [ "$failures" -lt 5 ]; do
    if ! i3-msg -t get_version >/dev/null 2>&1; then
        failures=$((failures + 1))
        sleep "$failures"
        continue
    fi
    failures=0
    update
    while read -r event; do
        case "$event" in
            '{"change":"new"'*|'{"change":"close"'*|'{"change":"move"'*) update ;;
            '{"change":"exit"'*) exit 0 ;;
        esac
    done < <(i3-msg -t subscribe -m '["window","shutdown"]')
    sleep 1
done
