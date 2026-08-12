-- init.lua — TS-first, no Lua LSP, proper Lua-table autocmds everywhere

vim.uv = vim.uv or vim.loop
vim.g.mapleader = ","

-- ---------- Basics ----------
vim.opt.termguicolors  = true
vim.opt.number         = true
vim.opt.relativenumber = true
vim.opt.signcolumn     = "yes"
vim.opt.linespace      = 1
vim.opt.linebreak      = true
vim.opt.expandtab      = true
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.foldmethod     = "syntax"
vim.opt.foldenable     = true
vim.opt.foldlevelstart = 99
vim.opt.background     = "dark"
vim.opt.completeopt    = { "menu", "menuone", "noselect" }

vim.fn.ge = vim.fn.ge or function() return false end

-- Quiet E31 when deleting non-existent maps
do
  local has_del = vim.keymap and vim.keymap.del
  if type(has_del) == "function" then
    local _del = vim.keymap.del
    vim.keymap.del = function(mode, lhs, opts)
      local ok, ret = pcall(_del, mode, lhs, opts)
      return ok and ret or false
    end
  end
end

-- ---------- Packer ----------
local function ensure_packer()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ "git","clone","--depth","1","https://github.com/wbthomason/packer.nvim", install_path })
    vim.cmd("packadd packer.nvim"); return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

require("packer").startup(function(use)
  use "wbthomason/packer.nvim"

  -- LSP + completion (TS only)
  use { "neovim/nvim-lspconfig", tag = "v2.*" } -- To get around deprecation message
  use "hrsh7th/nvim-cmp"
  use {'hrsh7th/cmp-nvim-lsp', commit = "39e2eda76828d88b773cc27a3f61d2ad782c922d"}
  use "hrsh7th/cmp-buffer"
  use "hrsh7th/cmp-path"
  use "hrsh7th/cmp-calc"
  use "L3MON4D3/LuaSnip"
  use "saadparwaiz1/cmp_luasnip"
  use "rafamadriz/friendly-snippets"

  -- UI/extras
  -- use "sainnhe/gruvbox-material"
  -- use "sainnhe/edge"
  use "sainnhe/sonokai"
  use "folke/zen-mode.nvim"
  use "github/copilot.vim"
  use "tpope/vim-commentary"
  use "f-person/git-blame.nvim"
  use "kyazdani42/nvim-web-devicons"
  use "romgrk/barbar.nvim"
  use "airblade/vim-gitgutter"
  use { 'nvim-lualine/lualine.nvim', requires = { 'nvim-tree/nvim-web-devicons', opt = true } }

  -- Tools
  use "nvim-lua/plenary.nvim"
  use "mfussenegger/nvim-lint"
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use { "iamcco/markdown-preview.nvim", run = function() vim.fn["mkdp#util#install"]() end }
  use { "junegunn/fzf", run = function() vim.fn.system({ "./install","--bin" }) end }
  use "junegunn/fzf.vim"

  if packer_bootstrap then require("packer").sync() end
end)

-- ---------- Colors ----------
-- vim.g.gruvbox_material_background         = "hard"
-- vim.g.gruvbox_material_foreground         = "material"
-- vim.g.gruvbox_material_enable_italic      = true
-- vim.g.gruvbox_material_better_performance = 1
-- vim.cmd.colorscheme("gruvbox-material")

-- vim.g.edge_dim_foreground = 1
-- vim.g.edge_float_style = 'dim'
-- vim.g.edge_style = 'neon'
-- vim.cmd.colorscheme("edge")

vim.g.sonokai_float_style = 'dim'
vim.g.sonokai_style = 'default'
vim.g.sonokai_disable_terminal_colors = 1
vim.g.sonokai_better_performance = 1
vim.cmd.colorscheme("sonokai")

-- ---------- Diagnostics ----------
vim.diagnostic.config({
  virtual_text = false,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
})
for t, icon in pairs({ Error=" ", Warn=" ", Hint=" ", Info=" " }) do
  local hl = "DiagnosticSign"..t
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
vim.cmd([[
  highlight DiagnosticUnderlineError gui=undercurl guisp=#ff5f5f
  highlight DiagnosticUnderlineWarn  gui=undercurl guisp=#ffd75f
  highlight DiagnosticUnderlineInfo  gui=undercurl guisp=#5fd7ff
  highlight DiagnosticUnderlineHint  gui=undercurl guisp=#5fff87
]])
vim.o.updatetime = 400
vim.api.nvim_create_autocmd("CursorHold", {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, border = "rounded", scope = "cursor" })
  end,
})

-- ---------- Keymaps ----------
vim.keymap.set("n","<C-Tab>",       ":BufferNext<CR>",           { noremap = true })
vim.keymap.set("n","<C-S-Tab>",     ":BufferPrevious<CR>",       { noremap = true })
vim.keymap.set("n","<C-w>",         ":BufferClose<CR>",          { noremap = true })
vim.keymap.set("n","<C-S-PageUp>",  ":BufferMovePrevious<CR>",   { noremap = true })
vim.keymap.set("n","<C-S-PageDown>",":BufferMoveNext<CR>",       { noremap = true })
vim.keymap.set("n","<C-t>",         ":enew<CR>",                 { noremap = true })
vim.keymap.set("n","<C-e>",         ":Files<CR>",                { noremap = true })
vim.keymap.set("n","<Esc>",         ":noh<CR><Esc>",             { noremap = true })

-- Copilot toggles / aliases
vim.g.copilot_enabled = 0
vim.api.nvim_create_user_command("CopilotEnable",  function() vim.g.copilot_enabled=1; vim.cmd("Copilot enable")  end, {})
vim.api.nvim_create_user_command("CopilotDisable", function() vim.g.copilot_enabled=0; vim.cmd("Copilot disable") end, {})
vim.keymap.set("n","<leader>ce", ":CopilotEnable<CR>",  { noremap = true })
vim.keymap.set("n","<leader>cd", ":CopilotDisable<CR>", { noremap = true })

vim.keymap.set("n","<leader>z",  ":ZenMode<CR>",               { noremap = true })
vim.keymap.set("n","<leader>md", ":MarkdownPreviewToggle<CR>", { noremap = true })
vim.keymap.set("n","<C-_>",      ":Commentary<CR>",            { noremap = true, silent = true })

-- LSP mappings
vim.keymap.set("n","ga",         vim.lsp.buf.code_action,    { silent = true })
vim.keymap.set("n","gd",         vim.lsp.buf.definition,     { silent = true })
vim.keymap.set("n","gi",         vim.lsp.buf.implementation, { silent = true })
vim.keymap.set("n","gr",         vim.lsp.buf.references,     { silent = true })
vim.keymap.set("n","K",          vim.lsp.buf.hover,          { silent = true })
vim.keymap.set("n","<leader>rn", vim.lsp.buf.rename,         { silent = true })
vim.keymap.set("n","<leader>f",  function() vim.lsp.buf.format { async = true } end, { silent = true })
vim.keymap.set("n","<leader>d",  vim.diagnostic.open_float,  { silent = true })
vim.keymap.set("n","[d",         vim.diagnostic.goto_prev,   { silent = true })
vim.keymap.set("n","]d",         vim.diagnostic.goto_next,   { silent = true })

-- Disable F1 help
vim.keymap.set("n","<F1>","<nop>")
vim.keymap.set("i","<F1>","<nop>")
vim.keymap.set("v","<F1>","<nop>")

-- Auto-launch fzf on `nvim .`
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.argv(0) == "." then vim.cmd("Files") end
  end,
})

-- Save current dir to file
vim.api.nvim_create_augroup("SaveDir", { clear = true })
vim.api.nvim_create_autocmd({ "BufWritePost","BufDelete" }, {
  group = "SaveDir",
  callback = function()
    vim.fn.writefile({ vim.fn.getcwd() }, vim.fn.expand("~/.vim/last_dir"))
  end,
})

-- Git blame
vim.g.gitblame_enabled = 1
vim.cmd("highlight gitblame ctermfg=8 cterm=italic")

-- ---------- Treesitter ----------
local ok_ts, ts_cfg = pcall(require, "nvim-treesitter.configs")
if ok_ts then
  ts_cfg.setup {
    ensure_installed = {
      "bash","c","go","javascript","typescript","lua","vim","vimdoc",
      "json","yaml","markdown","sql","html","css","scss",
    },
    highlight = { enable = true },
    indent    = { enable = true },
  }
end

-- ---------- Lualine -------------
require('lualine').setup {
  options = {
    theme = 'sonokai', -- or 'tokyonight', 'onedark', etc.
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { 'branch', 'diff', 'diagnostics' },
    lualine_c = { 'filename' },
    lualine_x = { 'encoding', 'fileformat', 'filetype' },
    lualine_y = { 'progress' },
    lualine_z = { 'location' }
  },
}


-- ---------- Completion (cmp) ----------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  -- completion = { autocomplete = false, keyword_length = 0 },
  snippet    = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping    = cmp.mapping.preset.insert({
    ["<C-k>"]     = cmp.mapping.select_prev_item(),
    ["<C-j>"]     = cmp.mapping.select_next_item(),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-@>"]     = cmp.mapping.complete(),
    ["<C-e>"]     = cmp.mapping.abort(),
    ["<CR>"]      = cmp.mapping.confirm({ select = true }),
    ["<Tab>"]     = cmp.mapping(function(fb)
      if cmp.visible() then cmp.confirm({ select = true })
      elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
      else fb() end
    end, { "i","s" }),
    ["<S-Tab>"]   = cmp.mapping(function(fb)
      if luasnip.jumpable(-1) then luasnip.jump(-1) else fb() end
    end, { "i","s" }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip"  },
    { name = "buffer"   },
    { name = "path"     },
    { name = "calc"     },
  },
  experimental = { ghost_text = true },
})

cmp.setup.filetype({ "html","css","scss","less","sql","sh","bash","zsh","markdown" }, {
  sources = { { name = "buffer" }, { name = "path" }, { name = "calc" }, { name = "luasnip" } },
})

-- ---------- LSP: TypeScript + Go ----------
local ok_lsp, lspconfig = pcall(require, "lspconfig")
if ok_lsp then
  local caps = require("cmp_nvim_lsp").default_capabilities()
  local util = lspconfig.util

  -- TypeScript / JavaScript
  local ts = lspconfig.ts_ls or lspconfig.tsserver
  ts.setup({
    capabilities = caps,
    single_file_support = true,
    filetypes = { "typescript","typescriptreact","javascript","javascriptreact","json" },
    root_dir = util.root_pattern("tsconfig.json","jsconfig.json","package.json",".git"),
    init_options = {
      hostInfo = "neovim",
      preferences = {
        includeCompletionsForModuleExports = true,
        includeCompletionsForImportStatements = true,
        includeAutomaticOptionalChainCompletions = true,
        includeCompletionsWithSnippetText = true,
        importModuleSpecifierPreference = "non-relative",
        importModuleSpecifierEnding = "auto",
        quotePreference = "auto",
      },
    },
  })

  -- lspconfig.eslint.setup({
  --   settings = {
  --     validate = "on",
  --     format = false, -- keep formatting separate unless you want ESLint to format
  --     workingDirectory = { mode = "auto" },
  --     codeActionOnSave = {
  --       enable = true,
  --       mode = "all",
  --     },
  --   },
  --   on_attach = function(client, bufnr)
  --     vim.api.nvim_create_autocmd("BufWritePre", {
  --       group = vim.api.nvim_create_augroup("EslintFix_" .. bufnr, { clear = true }),
  --       buffer = bufnr,
  --       callback = function()
  --         if vim.fn.exists(":EslintFixAll") > 0 then
  --           vim.cmd("EslintFixAll")
  --         end
  --       end,
  --     })
  --   end,
  -- })

  -- Go (gopls)
  -- lspconfig.gopls.setup({
  --   capabilities = caps,
  --   cmd = { "gopls" },
  --   filetypes = { "go", "gomod", "gowork", "gotmpl" },
  --   root_dir = util.root_pattern("go.work", "go.mod", ".git"),
  --   settings = {
  --     gopls = {
  --       analyses = {
  --         unusedparams = true,
  --         shadow       = true,
  --         nilness      = true,
  --         unusedwrite  = true,
  --       },
  --       staticcheck = true,
  --       gofumpt     = true,
  --     },
  --   },
  --   on_attach = function(client, bufnr)
  --     -- Format on save
  --     if client.server_capabilities.documentFormattingProvider then
  --       vim.api.nvim_create_autocmd("BufWritePre", {
  --         group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
  --         buffer = bufnr,
  --         callback = function()
  --           vim.lsp.buf.format({ async = false })
  --         end,
  --       })
  --     end
  --   end,
  -- })
  lspconfig.gopls.setup({
    capabilities = caps,
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_dir = util.root_pattern("go.work", "go.mod", ".git"),
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow       = true,
          nilness      = true,
          unusedwrite  = true,
          ST1000       = false, -- disable "package comment" check
          ST1003       = false, -- disable "poorly formed names" stylecheck
          ST1005       = false, -- disable "error strings should not be capitalized" check
        },
        staticcheck = true,
        gofumpt     = true,
      },
    },
    on_attach = function(client, bufnr)
      if client.name == "gopls" and client.server_capabilities.documentFormattingProvider then
        local group = vim.api.nvim_create_augroup("GoFormat_" .. bufnr, { clear = true })
  
        vim.api.nvim_create_autocmd("BufWritePre", {
          group = group,
          buffer = bufnr,
          callback = function()
            -- 1) goimports-like behavior: organize imports via gopls
            local params = vim.lsp.util.make_range_params()
            params.context = { only = { "source.organizeImports" } }
  
            local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
            if result then
              for client_id, res in pairs(result) do
                for _, r in pairs(res.result or {}) do
                  if r.edit then
                    local enc = (vim.lsp.get_client_by_id(client_id) or {}).offset_encoding or "utf-16"
                    vim.lsp.util.apply_workspace_edit(r.edit, enc)
                  elseif r.command then
                    vim.lsp.buf.execute_command(r.command)
                  end
                end
              end
            end
  
            -- 2) gofumpt-style formatting via gopls
            vim.lsp.buf.format({ bufnr = bufnr, async = false })
          end,
        })
      end
    end,
  })
end
