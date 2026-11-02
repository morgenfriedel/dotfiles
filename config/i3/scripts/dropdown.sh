#!/bin/bash

# Dropdown terminal on $mod+grave: shows or hides one floating st, starting
# it the first time. i3/config's for_window rule for the "dropdown" class
# sizes it and parks it in the scratchpad.

i3-msg -q '[class="^dropdown$"] scratchpad show, move position center' 2>/dev/null ||
    exec st -c dropdown
