# dotfiles

These dotfiles are for a Debian 12.1 hypervisor using KVM/QEMU. The hosted VMs will run Ubuntu 22.04+ along with the configs included here primarily for development purposes. Both of these installations are made from the server editions available at each distro's website (as opposed to the desktop editions) to keep unused packages and services to a minimum. 

Configs shared between the two systems are located in the `shared` folder. Configs unique to each system are located in their respective folders along with documentation for each disparity. Each folder also contains a complete package list installed on each system.

The host and VMs require specific configurations for Spice in order to support multiple displays. These dotfiles come configured to enable two monitors by default. More displays may be the default in the future.

## Debian

Currently version 12.1 (bookworm) with packages for KVM/libvirt as well as Python and C/C++.

```
Desktop Environment: Xfce4
Terminal: URxvt
Shell: bash
Editor: vim
VM Manager: virsh
Remote Display: spice
Total Packages: 2916
```

## Ubuntu

Currently version 16.04 (Xenial Xerus) with packages for Node and AWS.

```
Window Manager: i3
Terminal: st
Shell: bash
Editor: vim
Menu: dmenu
Remote Display: spice
Total Packages: 1745
```

