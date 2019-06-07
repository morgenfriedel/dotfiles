#!/bin/sh

xrandr --auto
xrandr --addmode Virtual-0 1920x1080;
xrandr --addmode Virtual-1 1920x1080;
xrandr --output Virtual-0 --mode 1920x1080;
xrandr --output Virtual-1 --mode 1920x1080 --right-of Virtual-0;
feh --bg-fill ~/.wallpaper/earthspace.jpg
spice-vdagent
