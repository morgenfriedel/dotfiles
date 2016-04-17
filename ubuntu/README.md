## Ubuntu 14.04 LTS Virtual Machine Setup

0. Download the Ubuntu 14.04 LTS image file.
0. Download and install a hypervisor.
0. Open hypervisor and select create a new Virtual Machine (VM).
0. Select the ISO option and specify the path to the Ubuntu ISO.
0. Complete the setup wizard to your desired specifications.
0. Proceed with the Ubuntu installation wizard.

## GNOME Flashback and Desktop Configuration

Gets rid of bloat and installs Gnome Flashback (Compiz) desktop. You will have to manually install Chrome and Sublime Text as well as any addons, plugings, etc.

`$ sudo apt-get update`

`$ sudo apt-get install conky xchat vim gnome-session-flashback compizconfig-settings-manager gnome-tweak-tool indicator-applet indicator-applet-appmenu indicator-applet-complete indicator-applet-session cpufrequtils desktop-base gnome-themes-standard vim-doc vim-scripts cairo-dock synaptic gdebi flashplugin-installer filezilla gimp htop irssi webhttrack httrack libmagickwand-dev imagemagick gconf-cleaner clamav clamtk acpi whois`

`$ sudo apt-get autoremove ubuntuone-client-data software-center ubuntu-desktop unity-webapps-common`

`$ sudo apt-get --purge remove zeitgeist`

`$ sudo apt-get autoremove zeitgeist-datahub zeitgeist-core deja-dup shotwell empathy evolution evolution-common kopete`

`$ sudo apt-get purge zeitgeist-datahub thunderbird*`

`$ sudo apt-get autoremove`

`$ gconf-cleaner`

`$ sudo apt-get update`

Run Compiz Config Settings Manager for ALT+TAB (window management), open Startup Applications to run remove any unnecessary applications and add cairo-dock to run on launch. CTRL+WIN/CMD+Right Click to add/remove Gnome menus, indicators, etc.
