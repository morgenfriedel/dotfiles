#!/usr/bin/env python3
"""Find where the launcher fits in polybar, on the focused monitor.

The launcher covers the window title, from just right of the "|" separator
up to the metrics, and fits however many workspaces there are right then.
polybar doesn't report where its modules are, so this grabs a thin strip of
the bar and works it out from the pixels:

- The metrics start where the longest empty stretch of bar ends.
- The separator is found by its exact pixels, saved in $XDG_RUNTIME_DIR the
  first time. To learn them, the strip is grabbed again with the title
  hidden for a moment; the first column that changes is the separator. That
  makes the title blink once per session, and on any later open where the
  saved pixels aren't found (e.g. on an empty workspace, where there's no
  title or separator and the blink can't be seen).

Prints "<output> <x> <width>", x relative to the monitor, or nothing if it
can't tell, in which case the launcher keeps its default position.
"""

import json
import os
import struct
import subprocess
import sys
import time

BG = bytes.fromhex("2e2a28")  # polybar's #282A2E, as BMP stores it (BGR)
TOP, HEIGHT = 8, 26            # the launcher field's rows within the bar
MARGIN = 12                    # space left beside the workspaces and metrics
MIN_WIDTH = 300
CACHE = os.path.join(os.environ.get("XDG_RUNTIME_DIR", "/tmp"), "bar-separator.json")


def i3(kind):
    return json.loads(subprocess.run(["i3-msg", "-t", kind], capture_output=True,
                                     text=True, check=True).stdout)


def strip(r):
    """The bar's rows as a list of columns, each column's pixels as bytes."""
    bmp = subprocess.run(["maim", "-f", "bmp", "-g",
                          f"{r['width']}x{HEIGHT}+{r['x']}+{r['y'] + TOP}"],
                         capture_output=True, check=True).stdout
    offset, = struct.unpack_from("<I", bmp, 10)
    width, height = struct.unpack_from("<ii", bmp, 18)
    depth = struct.unpack_from("<H", bmp, 28)[0] // 8
    stride = (width * depth + 3) & ~3
    rows = [bmp[offset + y * stride:][:width * depth] for y in range(abs(height))]
    return [b"".join(row[x * depth:x * depth + 3] for row in rows) for x in range(width)]


def is_plain(column):
    return column == BG * (len(column) // 3)


def longest_gap(cols):
    """(width, start) of the longest run of plain columns."""
    best, start = (0, 0), None
    for x in range(len(cols) + 1):
        plain = x < len(cols) and is_plain(cols[x])
        if plain and start is None:
            start = x
        elif not plain and start is not None:
            best = max(best, (x - start, start))
            start = None
    return best


def find(cols, pattern, end):
    """First x before end where pattern's columns appear, or None."""
    k = len(pattern)
    return next((x for x in range(end - k + 1) if cols[x:x + k] == pattern), None)


def learn(r, cols, end):
    """Hide the title for a moment and return the separator's columns."""
    subprocess.run(["polybar-msg", "action", "#xwindow.module_hide"], capture_output=True)
    try:
        time.sleep(0.04)  # let polybar redraw
        hidden = strip(r)
    finally:
        subprocess.run(["polybar-msg", "action", "#xwindow.module_show"], capture_output=True)
    gap, gap_start = longest_gap(hidden)
    # Changes outside that stretch (a metric ticking over) don't count.
    changed = next((x for x in range(gap_start, min(gap_start + gap, end))
                    if cols[x] != hidden[x]), None)
    if changed is None:
        return None
    stop = changed
    while stop < len(cols) and not is_plain(cols[stop]):
        stop += 1
    return cols[changed:stop]


def main():
    name = next(w["output"] for w in i3("get_workspaces") if w["focused"])
    r = next(o["rect"] for o in i3("get_outputs") if o["name"] == name)

    cols = strip(r)
    gap, gap_start = longest_gap(cols)
    right = gap_start + gap - MARGIN

    # The separator comes before the title, and the title before the gap; a
    # "|" further right is one of the metrics' separators.
    try:
        with open(CACHE) as f:
            pattern = [bytes.fromhex(c) for c in json.load(f)]
    except (OSError, ValueError):
        pattern = []
    sep = find(cols, pattern, gap_start) if pattern else None
    if sep is None:
        learned = learn(r, cols, gap_start)
        if learned:
            pattern = learned
            sep = find(cols, pattern, gap_start)
            with open(CACHE, "w") as f:
                json.dump([c.hex() for c in pattern], f)

    if sep is None:
        left = gap_start + MARGIN  # no title, so no separator either
    else:
        # Skip the stroke and the space after it: start where the title does.
        left = sep + len(pattern)
        while left < right and is_plain(cols[left]):
            left += 1
        left -= 2

    if right - left >= MIN_WIDTH:
        print(name, left, right - left)


try:
    main()
except (OSError, subprocess.CalledProcessError, StopIteration, struct.error, ValueError):
    sys.exit(0)
