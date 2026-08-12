#!/bin/sh
sleep 0.03

img="$1"

# only act on images
case "$(file --mime-type -Lb "$img")" in
  image/*) ;;
  *) exit 0 ;;
esac

pidfile="/tmp/lf-feh.pid"
link="/tmp/lf-feh-preview"

# point the symlink at the currently selected image
ln -sf -- "$img" "$link"

# if feh is already running, just let --reload pick up the change
if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
  exit 0
fi

# start one persistent feh window that "watches" the symlink
feh --auto-zoom --scale-down --reload 0.15 "$link" &
echo $! > "$pidfile"
