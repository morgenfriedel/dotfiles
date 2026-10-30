# dotfiles

Configuration for a bare-metal Ubuntu development laptop running i3.

```
OS:              Ubuntu 24.04 LTS (noble)
Window Manager:  i3
Bar:             polybar
Compositor:      picom
Terminal:        st (patched fork)
Shell:           bash
Editor:          nvim
File Manager:    lf
```

## Layout

```
home/       files that link into ~
config/     directories that link into ~/.config
packages/   package lists and manual-install notes
hosts/      per-machine overlays, plus configs for dormant machines
install.sh  symlinks everything into place
```

`install.sh` creates symlinks, so edits to a linked file are edits to this
repository. It backs up anything it would overwrite to
`~/.dotfiles-backup/<timestamp>/`.

```
./install.sh --dry-run   # show what would change
./install.sh             # link, prompting before replacing
./install.sh --force      # link, replacing without prompting
```

Packages are not installed automatically — see [`packages/`](packages/).

## Local and work settings

This repository is public, so nothing employer-specific lives in it.
Work paths, internal hosts, AWS profiles and similar go in `~/.bash_work`,
which is untracked and sourced last by `.bashrc`:

```bash
[ -f "$HOME/.bash_work" ] && . "$HOME/.bash_work"
```

Because it is sourced last, it can also override anything defined in
`.bash_aliases` or `.bash_functions`. Two functions are written with this in
mind — `gtp` (commit and push) and `asl` (AWS SSO login) — with generic
versions here and repo-specific ones layered on top locally.

`.gitconfig` follows the same pattern for `user.email` and similar: it
`[include]`s `~/.gitconfig.local`, an untracked file git silently ignores if
absent. There's no repo-tracked "work" variant of this — an email address is
enough to identify an employer, so it never touches git history, same as
`.bash_work`.

A few values (currently just the external-monitor name in `.xprofile`) are
genuinely just machine identity, not secrets, so they're handled differently:
`hosts/<name>/` can hold small overlay files (`xprofile`, so far) that
`install.sh` offers as a "which machine is this?" prompt, remembered in
`~/.dotfiles-host`, or set directly with `--host=NAME`.

## Shell

`.bashrc` loads in a fixed order: `.bash_path` (PATH and environment) →
`.bash_aliases` → `.bash_functions` → `.bash_prompt` → nvm → `.bash_work`.
`.profile` sources `.bash_path` directly so that non-interactive login shells
still get a usable PATH.

Readline and tmux are both in vi mode.

## Neovim

`config/nvim/init.lua` is the working config: treesitter-based highlighting,
nvim-cmp completion, and LSP for TypeScript and Go. Plugins are managed by
lazy.nvim, which bootstraps itself on first launch.

`config/nvim/text-config.vim` is a separate minimal prose-editing config
(Goyo, no UI chrome), reachable through the `tvim` alias.

Installation details are in [`packages/manual.md`](packages/manual.md).

## Bar and notifications

i3 runs `config/polybar/launch.sh` on start and on every restart
(`exec_always`; a plain reload skips it), so `$mod+Shift+r` rebuilds the bars — the fix for a stuck bar
or one left on the wrong monitor after plugging one in. It starts `bar/main`
(with the tray) on the primary monitor and `bar/secondary` on the others,
detects the battery and adapter names, and logs to
`$XDG_RUNTIME_DIR/polybar-<monitor>.log` rather than `~/.xsession-errors`.

Workspaces show an icon for each app on them instead of a number.
`config/i3/scripts/workspace-icons.sh` listens for windows opening, closing and
moving, and renames each workspace to `N:<icons>` (plain `N` when empty);
polybar strips the `N:`. Add apps to its `icon_for` table — the key is the
lowercased `WM_CLASS` class from `xprop`. Because names no longer equal the
number, i3 bindings use `workspace number N`. All bar icons are
Hack Nerd Font glyphs — emoji are not in the font and polybar warns on every
redraw it drops one.

The battery icon turns red below 20%, and at 10% the module becomes a red
block with a blinking warning. `config/i3/scripts/battery-alert.sh` adds dunst
notifications at 20%, 10% and 5%, then every minute below that. At 3% on
battery it warns, waits 60 seconds, then locks the screen and
suspends. `config/i3/scripts/lock.sh` is the lock: a pixelated, dimmed
screenshot. With `xsecurelock` installed, typing shows a password prompt in
the bar's colours (`lock-saver.py` draws the background); without it, stock
`i3lock` is used with no typing feedback. A plain colour stands in if the
image can't be made. Plugging in cancels; clicking or dismissing the warning cancels
auto-suspend until the next time the charger is unplugged.
`BATTERY_ALERT_TEST=1 config/i3/scripts/battery-alert.sh` runs the whole flow
on a 5-second cycle, alongside the real instance, without suspending.

`config/dunst/dunstrc` themes notifications to match the bar. Its keys are in
i3: `$mod+n` dismisses, `$mod+Shift+n` restores the last dismissed,
`$mod+Ctrl+n` dismisses all, and `$mod+Shift+d` toggles do-not-disturb (a bell
shows in the bar). Do-not-disturb holds everything, critical included, so
`battery-alert.sh` turns it off at 5%.

Media keys run `config/i3/scripts/volume.sh` (`pactl`, so PulseAudio or
PipeWire) and `brightness.sh`, each with a progress-bar popup;
play/pause/next/previous use `playerctl`. Brightness needs the `video` group
for direct access, otherwise it goes through systemd-logind — see
[`packages/manual.md`](packages/manual.md).

## Terminal

`st` is built from [morgenfriedel/st](https://github.com/morgenfriedel/st)
with six patches (alpha, anysize, boxdraw, clipboard, scrollback, xresources).
It is not vendored here — colors and transparency come from `.Xresources`,
which `.xprofile` merges at login.

`kitty.conf` exists only to remap Ctrl-Tab and Ctrl-Shift-Tab into escape
sequences Neovim can read, for buffer switching when kitty is used instead.

## hosts/

`hosts/<name>/` serves two different purposes depending on what it contains:

- Overlay files with a name `install.sh` recognizes (currently `xprofile`)
  are actively applied — see "Local and work settings" above.
- Everything else is reference-only. `hosts/hypervisor/` holds configs for a
  Debian 12 KVM/QEMU hypervisor that is currently dormant, kept so the
  machine can be rebuilt, not actively synced.
