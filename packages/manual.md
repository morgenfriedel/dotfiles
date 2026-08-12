# Manual installs

Everything here is installed outside `apt` and is not covered by
`install.sh`. Listed roughly in the order you'd want on a fresh machine.

## st (terminal)

Built from a personal fork with patches applied, in its own repository:

```
git clone git@github.com:morgenfriedel/st.git ~/builds/st
cd ~/builds/st
sudo apt install pkg-config build-essential libfontconfig1-dev libx11-dev libxft-dev
sudo make install
```

Patches currently applied (in `patches/`):

| Patch | Purpose |
| --- | --- |
| `st-alpha-20240814-a0274bc` | Background transparency (reads `.Xresources`) |
| `st-anysize-0.8.4` | Fill the window at any size, no gaps |
| `st-boxdraw_v2-0.8.5` | Crisp box-drawing glyphs |
| `st-clipboard-0.8.3` | Use the CLIPBOARD selection, not just PRIMARY |
| `st-scrollback-0.9.2` | Scrollback buffer |
| `st-xresources-20200604-9ba7ecf` | Read colors/font from `.Xresources` |

Transparency and colors come from `~/.Xresources`, which `.xprofile` merges
with `xrdb` at login.

## Neovim

Installed from the Ubuntu archive (`apt install neovim`), currently v0.10.4.

Plugins are managed by [packer.nvim](https://github.com/wbthomason/packer.nvim),
which bootstraps itself on first launch into
`~/.local/share/nvim/site/pack/packer/start/`. On a fresh machine:

1. `nvim` — packer clones itself and runs `PackerSync`
2. Restart, then `:TSUpdate` for treesitter parsers
3. `:call mkdp#util#install()` for markdown-preview

Language servers used by the config are installed separately: `gopls` (see
below) and `typescript-language-server` (see npm below).

> Note: packer has been archived upstream since 2023, and this config still
> targets it. Migrating to lazy.nvim is a known outstanding task.

## Go

Installed to `/usr/local/go` from <https://go.dev/dl/>, currently go1.25.1.
`GOROOT`, `GOPATH` and the bin directories are set in `.bash_path`.

Tools in `packages/go-tools.txt`:

```
xargs -n1 go install < <(grep -v '^#' packages/go-tools.txt)
```

## Node

Managed by [nvm](https://github.com/nvm-sh/nvm), sourced near the end of
`.bashrc`. Installed versions: 18.20.2, 20.12.2, 22.14.0 (default).

```
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
nvm install 22
```

Global packages are listed in `packages/npm-global.txt`:

```
npm install -g $(grep -v '^npm$' packages/npm-global.txt | tr '\n' ' ')
```

## Fonts

Nerd Fonts (Hack) for the devicons used by lualine, barbar and lf.
Download from <https://github.com/ryanoasis/nerd-fonts/releases>, extract to
`~/.local/share/fonts/`, then `fc-cache -fv`.

## theme.sh

Terminal colorscheme switcher, installed to `~/theme.sh` and invoked from
`.bashrc` with the `soft-server` theme.

```
curl -Lo ~/theme.sh https://git.io/theme.sh && chmod +x ~/theme.sh
```

## Other

- **AWS CLI v2** — installed from the bundled installer, not apt
- **Postman** — downloaded tarball
- **openvpn3** — from the OpenVPN apt repository (separate source list)
