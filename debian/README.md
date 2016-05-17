# Debian 8.4.0

Dotfiles, shell commands and scripts for Debian 8.4.0 complete with configuration notes.

## Install Debian

```bash
su
apt-get install openbox xchat tint2 conky vim menu obmenu git
apt-get remove evolution evolution-plugins
exit
cp /var/lib/openbox/debian-menu.xml ~/.config/openbox/debian-menu.xml
cp /etc/xdg/openbox/menu.xml ~/.config/openbox/menu.xml
cp /etc/xdg/openbox/rc.xml ~/.config/openbox/rc.xml
openbox --reconfigure
obmenu
```
Configure Openbox menu

## Running startup scripts

When Openbox loads, it will run the autostart script in the “~/.config/openbox” folder

```bash
vi autostart
!# /bash/sh
xrandr --output Virtual1 --mode 1360x768
conky &
tint2 &
exit 0
:wq
chmod 755 autostart
```
