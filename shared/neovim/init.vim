call plug#begin('~/.config/nvim/plugged')

Plug 'morhetz/gruvbox'
Plug 'github/copilot.vim'
Plug 'f-person/git-blame.nvim'
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-calc'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() } }

call plug#end()

" theme (gruvbox) configuration
colorscheme gruvbox
set background=dark

" git-blame configuration
let g:gitblame_enabled = 1
highlight gitblame ctermfg=8 cterm=italic

" nvim-lspconfig configuration
lua << EOF
local nvim_lsp = require'lspconfig'
nvim_lsp.tsserver.setup{}
EOF

" nvim-tree configuration
autocmd BufRead * NvimTreeOpen
nnoremap <C-t> :NvimTreeToggle<CR>
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>
let g:nvim_tree_ignore = [] 
lua << EOF
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 40,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    git_ignored = false,
  },
  on_attach = function(bufnr)
    local api = require("nvim-tree.api")
    local function opts(desc)
      return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end
    -- Apply default mappings
    api.config.mappings.default_on_attach(bufnr)
    -- Remove the default Ctrl+Shift+T mapping
    vim.keymap.del('n', '<C-t>', { buffer = bufnr })
  end
})
EOF

" barbar.nvim configuration
nmap <PageDown> :BufferNext<CR>
nmap <PageUp> :BufferPrevious<CR>
nmap <C-w> :BufferClose<CR>

" copilot configuration
nmap <silent> <C-Space> <Plug>(copilot-next)
nmap <silent> <C-y> <Plug>(copilot-accept)

" nvim-cmp configuration
lua << EOF
local cmp = require'cmp'
cmp.setup({
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<Tab>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'buffer' },
    { name = 'path' },
    { name = 'calc' },
  },
})
EOF

" native/core configuration
set number
set signcolumn=yes
set linespace=1
set expandtab
set tabstop=2
set shiftwidth=2
nnoremap <Esc> :noh<CR><Esc>
nmap <C-T> :NvimTreeToggle<CR>

function! FullQuit()
  " Get the total number of buffers
  let buffer_count = len(getbufinfo({'buflisted': 1}))

  " Check if NvimTree is open
  let nvim_tree_open = nvim_call_function('bufwinnr', ['NvimTree'])

  " If only one buffer and NvimTree is open
  if buffer_count == 1 && nvim_tree_open != -1
    " Close NvimTree
    execute 'NvimTreeClose'
  endif

  " Quit Neovim
  quit
endfunction

command! Q :call FullQuit()
