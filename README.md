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
