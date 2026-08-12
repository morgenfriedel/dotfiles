-- init.lua — treesitter-first, TypeScript + Go, managed by lazy.nvim
--
-- Targets Neovim 0.10.x. A few APIs here are deliberately the pre-0.11 forms
-- (vim.diagnostic.goto_prev/next, vim.lsp.util.make_range_params without an
-- encoding argument); they are marked below and need updating on 0.11+.

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
vim.opt.background     = "dark"
vim.opt.completeopt    = { "menu", "menuone", "noselect" }
vim.opt.updatetime     = 400

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase  = true

-- Persistent undo
vim.opt.undofile   = true
vim.opt.undolevels = 10000

-- Splits open where you expect them to
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Keep some context around the cursor
vim.opt.scrolloff     = 4
vim.opt.sidescrolloff = 8

vim.opt.mouse     = "a"
vim.opt.clipboard:append("unnamedplus")

-- Treesitter-based folding, all folds open on entry
vim.opt.foldmethod     = "expr"
vim.opt.foldexpr       = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldenable     = true
vim.opt.foldlevelstart = 99

-- ---------- lazy.nvim bootstrap ----------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP + completion
  -- Pinned to v2.x on purpose: lspconfig's newer majors require Neovim 0.11+.
  -- Unpin this when upgrading past 0.10.
  { "neovim/nvim-lspconfig", version = "^2" },
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-buffer",
  "hrsh7th/cmp-path",
  "hrsh7th/cmp-calc",
  "L3MON4D3/LuaSnip",
  "saadparwaiz1/cmp_luasnip",
  "rafamadriz/friendly-snippets",

  -- UI
  "sainnhe/sonokai",
  "folke/zen-mode.nvim",
  "nvim-tree/nvim-web-devicons",
  "romgrk/barbar.nvim",
  { "nvim-lualine/lualine.nvim", dependencies = { "nvim-tree/nvim-web-devicons" } },

  -- Editing
  "github/copilot.vim",
  "tpope/vim-commentary",
  { "kylechui/nvim-surround", version = "*" },

  -- Git: gitsigns replaces vim-gitgutter and git-blame.nvim
  "lewis6991/gitsigns.nvim",

  -- Tools
  "nvim-lua/plenary.nvim",
  "mfussenegger/nvim-lint",
  -- Pinned to master on purpose: nvim-treesitter's default branch is now the
  -- `main` rewrite, which drops the nvim-treesitter.configs API used below
  -- and requires Neovim 0.11+. Revisit alongside the lspconfig pin.
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate" },
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = function() vim.fn["mkdp#util#install"]() end,
  },
  { "junegunn/fzf", build = "./install --bin" },
  "junegunn/fzf.vim",
}, {
  install = { colorscheme = { "sonokai" } },
  change_detection = { notify = false },
})

-- ---------- Colors ----------
vim.g.sonokai_float_style = "dim"
vim.g.sonokai_style = "default"
vim.g.sonokai_disable_terminal_colors = 1
vim.g.sonokai_better_performance = 1

-- Custom highlights have to be reapplied whenever a colorscheme loads,
-- otherwise ZenMode or any :colorscheme call wipes them.
local function custom_highlights()
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { undercurl = true, sp = "#ff5f5f" })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { undercurl = true, sp = "#ffd75f" })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { undercurl = true, sp = "#5fd7ff" })
  vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { undercurl = true, sp = "#5fff87" })
  vim.api.nvim_set_hl(0, "GitSignsCurrentLineBlame", { fg = "#707880", italic = true })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("CustomHighlights", { clear = true }),
  callback = custom_highlights,
})

vim.cmd.colorscheme("sonokai")

-- ---------- Diagnostics ----------
vim.diagnostic.config({
  virtual_text = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "if_many" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
    },
  },
})

-- Show diagnostics under the cursor on hold, but stay out of the way of
-- hover, completion and non-file buffers.
vim.api.nvim_create_autocmd("CursorHold", {
  group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true }),
  callback = function()
    if vim.bo.buftype ~= "" then return end
    if vim.fn.pumvisible() == 1 then return end

    -- Don't stack floats on top of an existing one (e.g. from K)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then return end
    end

    vim.diagnostic.open_float(nil, {
      focus = false,
      border = "rounded",
      scope = "cursor",
      close_events = { "CursorMoved", "InsertEnter", "BufLeave", "WinScrolled" },
    })
  end,
})

-- ---------- Keymaps ----------
local map = function(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", { noremap = true, silent = true }, opts or {}))
end

-- Buffers (barbar), deliberately browser-like: <C-t> opens, <C-w> closes,
-- <C-Tab> cycles. Normal mode only, so <C-w> still deletes a word in insert.
map("n", "<C-Tab>",        "<Cmd>BufferNext<CR>")
map("n", "<C-S-Tab>",      "<Cmd>BufferPrevious<CR>")
map("n", "<C-w>",          "<Cmd>BufferClose<CR>")
map("n", "<C-S-PageUp>",   "<Cmd>BufferMovePrevious<CR>")
map("n", "<C-S-PageDown>", "<Cmd>BufferMoveNext<CR>")
map("n", "<C-t>",          "<Cmd>enew<CR>")

-- Since <C-w> is taken above, window commands move to <leader>w as a prefix:
-- <leader>wv splits vertically, <leader>ws horizontally, <leader>wq closes,
-- <leader>w= equalises, and so on. noremap keeps it out of the map above.
map("n", "<leader>w", "<C-w>")

-- The navigation half, which is most of what <C-w> was used for
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- Files / search
map("n", "<C-e>",  "<Cmd>Files<CR>")
map("n", "<Esc>",  "<Cmd>noh<CR>")

-- Copilot (off by default; toggle per session)
vim.g.copilot_enabled = 0
vim.api.nvim_create_user_command("CopilotEnable",  function() vim.g.copilot_enabled = 1; vim.cmd("Copilot enable")  end, {})
vim.api.nvim_create_user_command("CopilotDisable", function() vim.g.copilot_enabled = 0; vim.cmd("Copilot disable") end, {})
map("n", "<leader>ce", "<Cmd>CopilotEnable<CR>")
map("n", "<leader>cd", "<Cmd>CopilotDisable<CR>")

map("n", "<leader>z",  "<Cmd>ZenMode<CR>")
map("n", "<leader>md", "<Cmd>MarkdownPreviewToggle<CR>")
map("n", "<C-_>",      "<Cmd>Commentary<CR>")

-- LSP
map("n", "ga",         vim.lsp.buf.code_action)
map("n", "gd",         vim.lsp.buf.definition)
map("n", "gi",         vim.lsp.buf.implementation)
map("n", "gr",         vim.lsp.buf.references)
map("n", "K",          vim.lsp.buf.hover)
map("n", "<leader>rn", vim.lsp.buf.rename)
map("n", "<leader>f",  function() vim.lsp.buf.format({ async = true }) end)
map("n", "<leader>d",  vim.diagnostic.open_float)
-- 0.10 API. On 0.11+ these become vim.diagnostic.jump({ count = -1, float = true }).
map("n", "[d",         vim.diagnostic.goto_prev)
map("n", "]d",         vim.diagnostic.goto_next)

-- Disable F1 help
map({ "n", "i", "v" }, "<F1>", "<Nop>")

-- ---------- Autocommands ----------
-- Open the file picker when started as `nvim .`
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("FzfOnDirEnter", { clear = true }),
  callback = function()
    if vim.fn.argc() == 1 and vim.fn.argv(0) == "." then vim.cmd("Files") end
  end,
})

-- Remember the last directory worked in
vim.api.nvim_create_autocmd({ "BufWritePost", "BufDelete" }, {
  group = vim.api.nvim_create_augroup("SaveDir", { clear = true }),
  callback = function()
    local dir = vim.fn.expand("~/.vim")
    vim.fn.mkdir(dir, "p")
    vim.fn.writefile({ vim.fn.getcwd() }, dir .. "/last_dir")
  end,
})

-- ---------- Treesitter ----------
require("nvim-treesitter.configs").setup({
  ensure_installed = {
    "bash", "c", "go", "gomod", "gowork",
    "javascript", "typescript", "tsx",
    "lua", "vim", "vimdoc", "query",
    "json", "yaml", "markdown", "markdown_inline",
    "sql", "html", "css", "scss",
  },
  highlight = { enable = true },
  indent    = { enable = true },
})

-- ---------- Statusline ----------
require("lualine").setup({
  options = {
    theme = "sonokai",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { "branch", "diff", "diagnostics" },
    lualine_c = { "filename" },
    lualine_x = { "encoding", "fileformat", "filetype" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})

-- ---------- Git ----------
require("gitsigns").setup({
  current_line_blame = true,
  current_line_blame_opts = { delay = 300, virt_text_pos = "eol" },
  on_attach = function(bufnr)
    local gs = require("gitsigns")
    local function bmap(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
    end

    bmap("n", "]c", function() gs.nav_hunk("next") end, "Next hunk")
    bmap("n", "[c", function() gs.nav_hunk("prev") end, "Previous hunk")
    bmap("n", "<leader>hs", gs.stage_hunk,      "Stage hunk")
    bmap("n", "<leader>hr", gs.reset_hunk,      "Reset hunk")
    bmap("n", "<leader>hp", gs.preview_hunk,    "Preview hunk")
    bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    bmap("n", "<leader>hd", gs.diffthis,        "Diff this")
  end,
})

-- ---------- Surround ----------
require("nvim-surround").setup({})

-- ---------- Completion ----------
local cmp = require("cmp")
local luasnip = require("luasnip")
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
  snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
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
    end, { "i", "s" }),
    ["<S-Tab>"]   = cmp.mapping(function(fb)
      if luasnip.jumpable(-1) then luasnip.jump(-1) else fb() end
    end, { "i", "s" }),
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

-- Filetypes with no language server attached: skip the LSP source.
-- html/css/scss/json are no longer here, they have servers configured below.
cmp.setup.filetype({ "sql", "sh", "bash", "zsh", "markdown" }, {
  sources = { { name = "buffer" }, { name = "path" }, { name = "calc" }, { name = "luasnip" } },
})

-- ---------- LSP ----------
local lspconfig = require("lspconfig")
local caps = require("cmp_nvim_lsp").default_capabilities()
local util = lspconfig.util

-- TypeScript / JavaScript.
--
-- typescript-language-server resolves TypeScript from the workspace's
-- node_modules and fails to start when there isn't one, so a standalone 5.x
-- install provides a fallback for single files. The global typescript is 7.x
-- (the Go rewrite), which this server does not drive.
--
-- Important: init_options.tsserver.path OVERRIDES the workspace copy rather
-- than deferring to it, which would silently type-check your projects with a
-- different TypeScript than they pin -- the editor and CI would disagree. So
-- it is applied per-root below, only when the project has no TypeScript of
-- its own.
local tsserver_lib = vim.fn.expand("~/.local/share/nvim-tsserver/node_modules/typescript/lib")

lspconfig.ts_ls.setup({
  capabilities = caps,
  single_file_support = true,
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_dir = util.root_pattern("tsconfig.json", "jsconfig.json", "package.json", ".git"),

  on_new_config = function(new_config, root_dir)
    local workspace_ts = root_dir and (root_dir .. "/node_modules/typescript/lib")
    local use_workspace = workspace_ts and vim.fn.isdirectory(workspace_ts) == 1

    new_config.init_options = vim.tbl_deep_extend("force", new_config.init_options or {}, {
      -- nil lets the server resolve the project's own TypeScript
      tsserver = (not use_workspace and vim.fn.isdirectory(tsserver_lib) == 1)
        and { path = tsserver_lib }
        or vim.NIL,
    })
    if new_config.init_options.tsserver == vim.NIL then
      new_config.init_options.tsserver = nil
    end
  end,

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

-- JSON / HTML / CSS, all from vscode-langservers-extracted
lspconfig.jsonls.setup({ capabilities = caps })
lspconfig.html.setup({ capabilities = caps })
lspconfig.cssls.setup({ capabilities = caps })

-- ESLint is deliberately not configured here yet; linting is being worked
-- through separately against the CI setup.

-- Go
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
        ST1000       = false, -- package comment
        ST1003       = false, -- poorly formed names
        ST1005       = false, -- capitalized error strings
      },
      staticcheck = true,
      gofumpt     = true,
    },
  },
  on_attach = function(client, bufnr)
    if not client.server_capabilities.documentFormattingProvider then return end

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("GoFormat_" .. bufnr, { clear = true }),
      buffer = bufnr,
      callback = function()
        -- Organize imports (goimports equivalent) via gopls.
        -- 0.10 API: make_range_params takes no arguments here. On 0.11+ it
        -- requires a position encoding, e.g. make_range_params(0, client.offset_encoding).
        local params = vim.lsp.util.make_range_params()
        params.context = { only = { "source.organizeImports" } }

        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
        for client_id, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            if r.edit then
              local enc = (vim.lsp.get_client_by_id(client_id) or {}).offset_encoding or "utf-16"
              vim.lsp.util.apply_workspace_edit(r.edit, enc)
            elseif r.command then
              -- 0.10 API. Removed on 0.11+; use client:exec_cmd(r.command).
              vim.lsp.buf.execute_command(r.command)
            end
          end
        end

        vim.lsp.buf.format({ bufnr = bufnr, async = false })
      end,
    })
  end,
})
