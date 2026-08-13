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

Currently **v0.12.4**, installed from the official tarball — *not* from apt,
and not from the PPA:

- Ubuntu 24.04's archive only carries 0.10.4.
- `ppa:neovim-ppa/stable` publishes no package for noble at all.
- `ppa:neovim-ppa/unstable` carries a 0.12.0 dev snapshot, older than stable.

```sh
curl -LO https://github.com/neovim/neovim/releases/download/v0.12.4/nvim-linux-x86_64.tar.gz
sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
sudo mv /opt/nvim-linux-x86_64 /opt/nvim
sudo ln -sfn /opt/nvim/bin/nvim /usr/local/bin/nvim
```

`/usr/local/bin` precedes `/usr/bin`, so this shadows any apt copy while
leaving it installed as a fallback. To roll back: `sudo rm /usr/local/bin/nvim`.
Requires glibc ≥ 2.34 (noble has 2.39); otherwise use the `neovim-releases`
builds for older glibc.

Plugins are managed by [lazy.nvim](https://github.com/folke/lazy.nvim), which
bootstraps itself on first launch into `~/.local/share/nvim/lazy/`. On a fresh
machine just run `nvim` — lazy clones itself, installs everything, and
treesitter parsers build automatically from `ensure_installed`.

LSP uses the native `vim.lsp.config`/`vim.lsp.enable` API. nvim-lspconfig is
still installed, but only for the server definitions it ships in `lsp/*.lua`;
the deprecated `require('lspconfig').<server>.setup{}` framework is not used.

Two deliberate constraints in `init.lua`:

- `nvim-treesitter` is pinned to `branch = "master"`. The default `main`
  branch is a rewrite that drops the `nvim-treesitter.configs` API. Master is
  archived upstream but works; migrating is an outstanding task.
- `ts_ls` falls back to a standalone TypeScript install for single files —
  see below — but defers to a project's own TypeScript when it has one, so
  the editor and CI agree on versions.

Language servers are installed separately: `gopls` (see Go below),
`typescript-language-server` and `vscode-langservers-extracted` (see npm).

### Standalone TypeScript for ts_ls

`typescript-language-server` resolves TypeScript from the workspace and won't
start without one, so single files need a fallback. The global `typescript` is
7.x (the Go rewrite), which this server does not drive — hence a dedicated 5.x
install that nothing else touches:

```sh
mkdir -p ~/.local/share/nvim-tsserver && cd ~/.local/share/nvim-tsserver
npm init -y && npm install typescript@5
```

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
