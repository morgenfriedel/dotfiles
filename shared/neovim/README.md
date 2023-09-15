# NVVSCC (NeoVim VSCode Clone)

This whole setup is just based on me trying to clone the features I use in VSCode over to NeoVim. It is a work in progress.

# Installation

1. Install NeoVim by going to their GitHub and downloading the lateset stable version (v0.9.2 at this time of writing).

2. Intialize the configutation file (copy `init.vim` to the `~/.config/nvim` directory):

```
mkdir -p ~/.config/nvim && cp init.vim ~/.config/nvim
```

3. Install the plugin manager (`vim-plugin`):

```
sh -c 'curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```

4. Open `nvim` and then run the `:PlugInstall` command.

5. Restart `nvim` and then run `:call mkdp#util#install()` for the Markdown Preview plugin.

