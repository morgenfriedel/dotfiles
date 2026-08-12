# Debian hypervisor (dormant)

Configs for a Debian 12 (bookworm) server running KVM/QEMU via libvirt,
hosting Ubuntu development VMs over Spice. Not currently running — kept here
so the machine can be rebuilt, not actively synced.

```
Base:            Debian 12 (bookworm), server edition
Desktop:         Xfce4
Terminal:        URxvt
Shell:           bash
VM Manager:      virsh / virt-manager
Remote Display:  spice
```

## Contents

| File | Notes |
| --- | --- |
| `.bash_aliases` | Aliases specific to the host, including virsh helpers |
| `.Xdefaults` | URxvt configuration |
| `packages` | Full `dpkg` list as of the last sync (2023) |

## Notes for a rebuild

The host distro is independent of what the guests run — KVM is a mainline
kernel module and guests talk to virtio devices, not to the host userland, so
a Debian host with Ubuntu guests shares no toolchain or ABI surface. Debian
stable was chosen for the host precisely because it moves slowly.

Spice needs explicit per-VM configuration to drive more than one display; the
guest also needs `spice-vdagent` running and the virtual outputs added with
`xrandr` (there was a `.scripts/xrandr.sh` doing this on the guest side —
see git history before the 2026 restructure).

The Adwaita-Xfce GTK theme that used to be vendored here was removed; install
it from the archive instead.
