#!/bin/sh
id="$1"
f="$2"

statefile="/tmp/lf-preview-state-$id"
mime="$(file --mime-type -Lb "$f")"

is_image=0
case "$mime" in
  image/*) is_image=1 ;;
esac

prev="$(cat "$statefile" 2>/dev/null || true)"

if [ "$is_image" -eq 1 ]; then
  # update feh (your working script)
  ~/.config/lf/feh-preview.sh "$f"

  # hide pane only if not already hidden
  if [ "$prev" != "image" ]; then
    lf -remote "send $id :set preview false; set drawbox false"
    echo "image" >"$statefile"
  fi
else
  # show pane only if not already shown
  if [ "$prev" != "text" ]; then
    lf -remote "send $id :set preview true; set drawbox true"
    echo "text" >"$statefile"
  fi
fi

