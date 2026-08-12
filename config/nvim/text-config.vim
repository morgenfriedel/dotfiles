" Set the leader key
let mapleader =","

" Check and install vim-plug if not already installed
if ! filereadable(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim"'))
	echo "Downloading vim-plug to manage plugins..."
	silent !mkdir -p ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/
	silent !curl "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" > ${XDG_CONFIG_HOME:-$HOME/.config}/nvim/autoload/plug.vim
	autocmd VimEnter * PlugInstall
endif

" Plugin management
call plug#begin(system('echo -n "${XDG_CONFIG_HOME:-$HOME/.config}/nvim/plugged"'))
Plug 'junegunn/goyo.vim'
Plug 'github/copilot.vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
call plug#end()

" Basic editor settings
set title
set bg=light
set mouse=a
set clipboard+=unnamedplus
set noshowmode
set noruler
set laststatus=0
set noshowcmd
set nocompatible
set encoding=utf-8
set number relativenumber

" Disable automatic commenting on newline
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Key mappings
map <leader>f :Goyo \| set bg=light \| set linebreak<CR> " Activate Goyo and center the text
nnoremap c "_c " Redefine 'c' to change without affecting the clipboard

" Copilot keybindings
nmap <silent> <C-Tab> <Plug>(copilot-next)
nmap <silent> <C-Enter> <Plug>(copilot-accept)

command! DisableCopilot nmap <silent> <C-Tab> <Nop> | nmap <silent> <C-Enter> <Nop>
command! EnableCopilot nmap <silent> <C-Tab> <Plug>(copilot-next) | nmap <silent> <C-Enter> <Plug>(copilot-accept)


" vim-commentary for quick commenting
" Uses gcc to comment out a line or gc to comment out a selection

" General usability improvements
set splitbelow splitright " Make new splits open in intuitive locations
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Automatic actions
" Enter Goyo mode upon entering Neovim with a document
autocmd VimEnter * Goyo
" Automatically delete trailing whitespace and newlines at end of file on save
autocmd BufWritePre * %s/\s\+$//e
autocmd BufWritePre * %s/\n\+\%$//e

" Function to toggle UI elements
function! ToggleUI()
    if &laststatus == 2
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction
nnoremap <leader>h :call ToggleUI()<CR>

" Start Neovim directly in Goyo mode
autocmd VimEnter * Goyo

