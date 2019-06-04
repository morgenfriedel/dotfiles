set number
" Shows line number
set relativenumber
" Shows relative line numbers
set nocompatible
"This setting prevents vim from emulating the original vi's bugs and limitations.

"set autoindent
"set smartindent
"The first setting tells vim to use "autoindent" (that is, use the current line's indent level to set the indent level of new lines). The second makes vim attempt to intelligently guess the indent level of any new line based on the previous line, assuming the source file is in a C-like language. Combined, they are very useful in writing well-formatted source code.

set tabstop=4
set shiftwidth=4
set expandtab
"I prefer 4-space tabs to 8-space tabs. The first setting sets up 4-space tabs, and the second tells vi to use 4 spaces when text is indented (auto or with the manual indent adjustmenters.)

set showmatch
"This setting will cause the cursor to very briefly jump to a brace/parenthese/bracket's "match" whenever you type a closing or opening brace/parenthese/bracket. I've had almost no mismatched-punctuation errors since I started using this setting.

"set guioptions-=T
"I find the toolbar in the GUI version of vim (gvim) to be somewhat useless visual clutter. This option gets rid of the toolbar.

"set vb t_vb=
"This setting prevents vi from making its annoying beeps when a command doesn't work. Instead, it briefly flashes the screen -- much less annoying.

set ruler
"This setting ensures that each window contains a statusline that displays the current cursor position.

"set nohls
"By default, search matches are highlighted. I find this annoying most of the time. This option turns off search highlighting. You can always turn it back on with :set hls.

set incsearch
"With this nifty option, vim will search for text as you enter it. For instance, if you type /bob to search for bob, vi will go to the first "b" after you type the "b," to the first "bo" after you type the "o," and so on. It makes searching much faster, since if you pay attention you never have to enter more than the minimum number of characters to find your target location. Make sure that you press Enter to accept the match after vim finds the location you want.

"set virtualedit=all

" Only useful if using windows
" Opens gvim using the entire screen
" autocmd GuiEnter * simalt ~x


" Favorite Color Scheme
if has("gui_running")
   colorscheme torte
   " Remove Toolbar
   set guioptions-=T
   "Terminus is AWESOME
   set guifont=Lucida_Console:h9 
else
   set guifont=Lucida_Console:h9 
   "colorscheme metacosm
endif

" Enable Ctrl-C, Ctrl-V, select with cursor etc. as in mswin
source $VIMRUNTIME/mswin.vim
behave mswin


set rtp+=$GOROOT/misc/vim
"filetype plugin indent on

syntax on

set clipboard=unnamedplus
