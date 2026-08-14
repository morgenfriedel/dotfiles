-- init.lua — treesitter-first, TypeScript + Go, managed by lazy.nvim
--
-- Targets Neovim 0.11+: uses the native vim.lsp.config/vim.lsp.enable API
-- (see below) and vim.diagnostic.jump for diagnostic navigation.

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
  -- Kept only for the server definitions in its lsp/*.lua; the deprecated
  -- require('lspconfig') framework is no longer used, so no version pin.
  "neovim/nvim-lspconfig",
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

  -- Git.
  -- gitsigns: in-buffer hunks (replaces vim-gitgutter and git-blame.nvim)
  -- fugitive: porcelain -- status, staging, commits, 3-way conflict splits
  -- diffview: branch-wide review, GitHub Compare style, plus a merge tool
  "lewis6991/gitsigns.nvim",
  "tpope/vim-fugitive",
  { "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- Tools
  "nvim-lua/plenary.nvim",
  "mfussenegger/nvim-lint",
  -- Pinned to master on purpose: nvim-treesitter's default branch is now the
  -- `main` rewrite, which drops the nvim-treesitter.configs API used below
  -- and requires Neovim 0.11+. Revisit alongside the lspconfig pin.
  { "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate" },
  {
    -- mkdp#util#install() downloads the prebuilt preview server into app/bin.
    -- It is only defined once the plugin is sourced, which lazy hasn't done
    -- at build time under ft/cmd loading -- hence the explicit load first.
    -- Without it the build silently no-ops and :MarkdownPreview exists but
    -- never starts. (Do not swap this for a yarn build: yarn 4 migrates the
    -- bundled app to PnP and exceeds lazy's build timeout.)
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    build = function()
      require("lazy").load({ plugins = { "markdown-preview.nvim" } })
      vim.fn["mkdp#util#install"]()
    end,
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

-- Copilot (off by default; toggle per session).
-- These report their new state: the mappings are silent and Copilot itself
-- says nothing when toggled, so without the notify there is no way to tell
-- whether the keypress registered short of typing and waiting for a ghost
-- suggestion.
vim.g.copilot_enabled = 0

local function copilot_set(on)
  vim.g.copilot_enabled = on and 1 or 0
  vim.cmd("Copilot " .. (on and "enable" or "disable"))
  vim.notify("Copilot " .. (on and "enabled" or "disabled"), vim.log.levels.INFO)
end

vim.api.nvim_create_user_command("CopilotEnable",  function() copilot_set(true)  end, {})
vim.api.nvim_create_user_command("CopilotDisable", function() copilot_set(false) end, {})
vim.api.nvim_create_user_command("CopilotToggle",  function() copilot_set(vim.g.copilot_enabled ~= 1) end, {})

map("n", "<leader>ce", "<Cmd>CopilotEnable<CR>")
map("n", "<leader>cd", "<Cmd>CopilotDisable<CR>")
map("n", "<leader>ct", "<Cmd>CopilotToggle<CR>")

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
map("n", "[d",         function() vim.diagnostic.jump({ count = -1, float = true }) end)
map("n", "]d",         function() vim.diagnostic.jump({ count = 1, float = true }) end)

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

    -- In a diff (diffview, :Gvdiffsplit, vimdiff) ]c/[c are Vim's builtin
    -- next/previous-change motions, which is what you actually want there.
    -- Outside a diff they navigate gitsigns hunks.
    bmap("n", "]c", function()
      if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
    end, "Next hunk / change")
    bmap("n", "[c", function()
      if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
    end, "Previous hunk / change")

    bmap("n", "<leader>hs", gs.stage_hunk,      "Stage hunk")
    bmap("n", "<leader>hr", gs.reset_hunk,      "Reset hunk")
    bmap("n", "<leader>hp", gs.preview_hunk,    "Preview hunk")
    bmap("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    bmap("n", "<leader>hd", gs.diffthis,        "Diff this")
  end,
})

-- Diffview: branch-wide review and merge-conflict resolution.
-- Note the three-dot range in <leader>gd: like GitHub's Compare view it
-- diffs against the merge base, so commits that landed on master after you
-- branched do not show up as part of your changes.
require("diffview").setup({
  enhanced_diff_hl = true,
  view = {
    -- During a merge, open the 3-way layout: OURS and THEIRS above the
    -- working copy, with BASE reachable via :DiffviewToggleFiles / 4-way.
    merge_tool = { layout = "diff3_mixed", disable_diagnostics = true },
  },
})

-- Resolve the repo's default branch rather than assuming master: prefer what
-- the remote advertises as origin/HEAD, then fall back through the usual names.
local function base_ref()
  local head = vim.fn.systemlist("git symbolic-ref --quiet --short refs/remotes/origin/HEAD")[1]
  if vim.v.shell_error == 0 and head and head ~= "" then return head end
  for _, ref in ipairs({ "origin/main", "origin/master", "main", "master" }) do
    vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref })
    if vim.v.shell_error == 0 then return ref end
  end
  return nil
end

map("n", "<leader>gd", function()
  local base = base_ref()
  if not base then
    vim.notify("No default branch found; showing uncommitted changes", vim.log.levels.WARN)
    vim.cmd("DiffviewOpen")
  else
    vim.cmd("DiffviewOpen " .. base .. "...HEAD")
  end
end, { desc = "Review branch vs default branch" })
map("n", "<leader>gD", "<Cmd>DiffviewOpen<CR>",                     { desc = "Review uncommitted changes" })
map("n", "<leader>gh", "<Cmd>DiffviewFileHistory %<CR>",            { desc = "History of this file" })
map("n", "<leader>gH", "<Cmd>DiffviewFileHistory<CR>",              { desc = "History of this branch" })
map("n", "<leader>gq", "<Cmd>DiffviewClose<CR>",                    { desc = "Close diffview" })

-- Fugitive: staging, commits, and three-way conflict splits
map("n", "<leader>gs", "<Cmd>Git<CR>",           { desc = "Git status" })
map("n", "<leader>gb", "<Cmd>Git blame<CR>",     { desc = "Git blame" })
map("n", "<leader>gm", "<Cmd>Git mergetool<CR>", { desc = "Conflicted files to quickfix" })

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
--
-- Uses the native vim.lsp.config/vim.lsp.enable API (Neovim 0.11+).
-- nvim-lspconfig is still installed, but only for the server definitions it
-- ships in lsp/*.lua (cmd, filetypes, root_dir) -- not as a "framework".
-- require('lspconfig').<server>.setup{} is deprecated and removed in v3.
--
-- Anything set here is merged on top of those base definitions, so the
-- upstream root-detection logic (monorepo lock files for ts_ls, module cache
-- for gopls) is inherited rather than reimplemented.

local caps = require("cmp_nvim_lsp").default_capabilities()

-- Completion capabilities apply to every server
vim.lsp.config("*", { capabilities = caps })

-- TypeScript / JavaScript.
--
-- typescript-language-server resolves TypeScript from the workspace's
-- node_modules and fails to start when there isn't one, so a standalone 5.x
-- install provides a fallback for single files. The global typescript is 7.x
-- (the Go rewrite), which this server does not drive.
--
-- Important: initializationOptions.tsserver.path OVERRIDES the workspace copy
-- rather than deferring to it, which would silently type-check projects with
-- a different TypeScript than they pin -- the editor and CI would disagree.
-- So it is applied per-root in before_init, only when the project has no
-- TypeScript of its own.
local tsserver_lib = vim.fn.expand("~/.local/share/nvim-tsserver/node_modules/typescript/lib")

vim.lsp.config("ts_ls", {
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

  before_init = function(params, config)
    local root = config.root_dir
    local workspace_ts = root and (root .. "/node_modules/typescript/lib")
    local use_workspace = workspace_ts and vim.fn.isdirectory(workspace_ts) == 1

    params.initializationOptions = params.initializationOptions or {}
    if use_workspace or vim.fn.isdirectory(tsserver_lib) == 0 then
      -- nil lets the server resolve the project's own TypeScript
      params.initializationOptions.tsserver = nil
    else
      params.initializationOptions.tsserver = { path = tsserver_lib }
    end
  end,
})

-- JSON / HTML / CSS, all from vscode-langservers-extracted
vim.lsp.config("jsonls", {})
vim.lsp.config("html", {})
vim.lsp.config("cssls", {})

-- ESLint is deliberately not configured here yet; linting is being worked
-- through separately against the CI setup.

-- Go
vim.lsp.config("gopls", {
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
    if not client:supports_method("textDocument/formatting") then return end

    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("GoFormat_" .. bufnr, { clear = true }),
      buffer = bufnr,
      callback = function()
        -- Organize imports (goimports equivalent) via gopls
        local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
        params.context = { only = { "source.organizeImports" }, diagnostics = {} }

        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, 1000)
        for _, res in pairs(result or {}) do
          for _, r in pairs(res.result or {}) do
            -- Since 0.12 an LSP JSON null arrives as vim.NIL, which is truthy
            -- in Lua, so a bare `if r.edit then` would take the wrong branch.
            if r.edit and r.edit ~= vim.NIL then
              vim.lsp.util.apply_workspace_edit(r.edit, client.offset_encoding)
            elseif r.command and r.command ~= vim.NIL then
              client:exec_cmd(r.command, { bufnr = bufnr })
            end
          end
        end

        vim.lsp.buf.format({ bufnr = bufnr, async = false })
      end,
    })
  end,
})

vim.lsp.enable({ "ts_ls", "jsonls", "html", "cssls", "gopls" })
