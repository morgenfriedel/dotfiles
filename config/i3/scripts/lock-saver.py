#!/usr/bin/env python3
"""xsecurelock saver module (see lock.sh).

Shows the pixelated screenshot lock.sh made, cropped to this saver's monitor.
xsecurelock runs one per monitor and passes the window to draw on in
$XSCREENSAVER_WINDOW. That window lives under the compositor overlay, where
tools that look windows up from the root (ImageMagick's display) can't find
it, so Tk embeds into it by ID instead. SIGTERM at unlock ends the process.

If anything fails, it exits and the lock shows the plain background colour.
"""

import os
import re
import subprocess
import tkinter as tk

window = os.environ["XSCREENSAVER_WINDOW"]

# Tk only learns the embedding window's size after mapping, so ask X directly.
info = subprocess.run(["xwininfo", "-id", window], capture_output=True, text=True, check=True).stdout
x, y, w, h = (int(re.search(rf"{key}:\s+(-?\d+)", info).group(1))
              for key in ("Absolute upper-left X", "Absolute upper-left Y", "Width", "Height"))

root = tk.Tk(use=window)

full = tk.PhotoImage(file=os.environ["LOCK_IMAGE"])
crop = tk.PhotoImage(width=w, height=h)
crop.tk.call(crop, "copy", full, "-from", x, y, x + w, y + h)
del full

tk.Label(root, image=crop, borderwidth=0, highlightthickness=0).pack(fill="both", expand=True)
root.mainloop()
