#!/usr/bin/env python3
"""Clipboard history.

  clipboard.py daemon   started from i3/config; records copied text
  clipboard.py menu     $mod+v: pick an entry (launcher.sh) to copy it again

Only the clipboard (Ctrl+C) is recorded, not the mouse selection. The history
lives in $XDG_RUNTIME_DIR, which is in memory: it's never written to disk and
is gone at logout.

Password copies are skipped: anything marked with the
x-kde-passwordManagerHint target (KeePassXC and others), and anything copied
while `pass` is running. `pass -c` gives no hint, but it stays running until
it clears the clipboard 45 seconds later.
"""

import fcntl
import json
import os
import subprocess
import sys

LIMIT = 50
MAX_BYTES = 100_000
RUNTIME = os.environ.get("XDG_RUNTIME_DIR", "/tmp")
HISTORY = os.path.join(RUNTIME, "clipboard-history.json")
CLEAR = "x  clear history"
MENU = [os.path.join(os.path.dirname(os.path.realpath(__file__)), "launcher.sh"),
        "list", "clipboard"]


def load():
    try:
        with open(HISTORY) as f:
            return json.load(f)
    except (OSError, ValueError):
        return []


def save(items):
    tmp = HISTORY + ".tmp"
    with os.fdopen(os.open(tmp, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), "w") as f:
        json.dump(items, f)
    os.replace(tmp, HISTORY)


def pass_running():
    for pid in os.listdir("/proc"):
        if not pid.isdigit():
            continue
        try:
            with open(f"/proc/{pid}/cmdline", "rb") as f:
                argv = f.read().split(b"\0")
        except OSError:
            continue
        # pass is a bash script: argv is "bash /usr/bin/pass ...".
        if any(os.path.basename(a) == b"pass" for a in argv[:2]):
            return True
    return False


def daemon():
    import gi
    gi.require_version("Gdk", "3.0")
    gi.require_version("Gtk", "3.0")
    from gi.repository import Gdk, Gtk

    # One per session; an i3 restart doesn't start a second.
    lock = open(os.path.join(RUNTIME, "clipboard.lock"), "w")
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        sys.exit(0)

    clip = Gtk.Clipboard.get(Gdk.SELECTION_CLIPBOARD)

    def changed(*_):
        ok, targets = clip.wait_for_targets()
        if ok and any(t.name() == "x-kde-passwordManagerHint" for t in targets):
            return
        if pass_running():
            return
        text = clip.wait_for_text()
        if not text or not text.strip() or len(text.encode()) > MAX_BYTES:
            return
        save(([text] + [t for t in load() if t != text])[:LIMIT])

    clip.connect("owner-change", changed)
    Gtk.main()


def menu():
    items = load()
    if not items:
        subprocess.run(["dunstify", "-a", "clipboard", "-u", "low", "-t", "2000",
                        "Clipboard history is empty", "Copy something first."])
        return
    lines = [f"{n:<2} {' '.join(t.split())[:150]}" for n, t in enumerate(items)]
    choice = subprocess.run(MENU, input="\n".join(lines + [CLEAR]),
                            capture_output=True, text=True).stdout.strip("\n")
    if choice == CLEAR:
        os.remove(HISTORY)
        return
    try:
        text = items[int(choice.split(maxsplit=1)[0])]
    except (ValueError, IndexError):
        return  # cancelled, or typed something that isn't an entry
    subprocess.run(["xclip", "-selection", "clipboard"], input=text, text=True)


if __name__ == "__main__":
    {"daemon": daemon, "menu": menu}.get(sys.argv[1] if len(sys.argv) > 1 else "",
                                         lambda: sys.exit("usage: clipboard.py daemon|menu"))()
