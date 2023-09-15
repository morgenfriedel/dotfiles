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
nnoremap <C-t> :NvimTreeToggle<CR>
nnoremap <C-h> :wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>
let g:nvim_tree_ignore = [] 
lua << EOF
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width = 30,
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
    ['<Enter>'] = cmp.mapping.confirm({ select = true }),
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
nnoremap <Esc> :noh<CR><Esc>
nmap <C-w> :BufferClose<CR>
let g:last_closed_file = ''
autocmd BufDelete,BufWipeout * let g:last_closed_file = expand('<afile>:p')
nmap <C-S-T> :if g:last_closed_file != ''<Bar>execute 'edit' fnameescape(g:last_closed_file)<Bar>endif<CR>
