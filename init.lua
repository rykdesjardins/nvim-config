-- Neovim configuration file with lazy.nvim plugin manager
-- Also configures neovide settings, LSP, Telescope, Nvim Tree.
--
-- Requires a patched version of Comic Mono from nerd fonts :
--   https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono
--
-- Otherwise requires the new typescript server (vtsls) and biome installed via npm.

vim.g.mapleader = "#"
vim.opt.clipboard = "unnamedplus"

-- Ensure site directory is in runtimepath for Treesitter
vim.opt.rtp:append("/home/ryk/.local/share/nvim/site")

-- Workaround for Neovim 0.13-dev Treesitter bug:
-- Some parsers (like markdown) might pass TSTree or other non-node objects
-- where a TSNode is expected, causing a crash in get_range.
local ts = vim.treesitter
if ts and ts.get_range then
  local orig_get_range = ts.get_range
  ts.get_range = function(node, ...)
    if type(node) ~= 'userdata' or not node.range then
      if type(node) == 'userdata' and node.root then
        node = node:root()
      else
        return { 0, 0, 0, 0, 0, 0 }
      end
    end
    return orig_get_range(node, ...)
  end
end

-- Also patch LanguageTree if possible
local ok_lt, lt = pcall(require, 'vim.treesitter.languagetree')
if ok_lt and lt.set_included_regions then
  local orig_set_included_regions = lt.set_included_regions
  lt.set_included_regions = function(self, new_regions)
    for _, region in ipairs(new_regions) do
      for i, range in ipairs(region) do
        if type(range) == 'userdata' and not range.range and range.root then
          region[i] = range:root()
        end
      end
    end
    return orig_set_included_regions(self, new_regions)
  end
end

if vim.g.neovide then
  vim.o.guifont = "Comic Mono:h11"
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_left = 10
  vim.g.neovide_padding_right = 10

  vim.g.neovide_cursor_vfx_mode = {"pixiedust"}
  vim.g.neovide_cursor_vfx_particle_density = 5
  vim.g.neovide_cursor_vfx_opacity = 300.0
  vim.g.neovide_cursor_vfx_particle_lifetime = 2
  vim.g.neovide_cursor_vfx_particle_highlight_lifetime = 1
  vim.g.neovide_cursor_vfx_particle_speed = 50.0
  vim.g.neovide_cursor_vfx_particle_phase = 5
  vim.g.neovide_cursor_vfx_particle_curl = 1
end

-- Enable filetype plugins and indentation
vim.cmd("filetype plugin indent on")

-- General settings
vim.opt.encoding = "utf-8"
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = false
vim.opt.number = true
vim.opt.laststatus = 3
vim.opt.showmode = false

vim.keymap.set({"n", "v"}, "<leader>a", vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ac", vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set("n", "<leader>qf", function()
  vim.lsp.buf.code_action({
    filter = function(action)
      -- Some servers mark fix actions with certain kinds
      return action.kind == "quickfix"
    end,
    apply = true
  })
end, { noremap = true, silent = true })


-- Syntax highlighting
vim.cmd("syntax on")

-- Global variables (legacy, kept for compatibility)
vim.g.javascript_plugin_flow = 1
vim.g.webdevicons_enable = 1
vim.g.webdevicons_enable_nerdtree = 1

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins setup
require("lazy").setup({
  -- Theme plugins
  { "vim-scripts/Gummybears" },
  { "sainnhe/edge" },
  { "tomasr/molokai" },
  { "folke/tokyonight.nvim" },
  { "dm1try/golden_size" },
  { "deparr/tairiki.nvim" },
  { "tomasiser/vim-code-dark" },
  { "w0ng/vim-hybrid" },
  { "catppuccin/nvim", name = "catppuccin" },
  { "rainglow/vim" },

  -- GraphQL syntax (not covered by Treesitter in all cases)
  { "jparise/vim-graphql" },

  -- Git integration
  { "lewis6991/gitsigns.nvim", config = true },

  -- Statusline / UI
  { "itchyny/lightline.vim" },
  { "romgrk/barbar.nvim" },

  -- Editorconfig
  { "editorconfig/editorconfig-vim" },

  -- Icons and sidebar file explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        git = {
          enable = true,
        },
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          icons = {
            show = {
              git = true,
              folder = true,
              file = true,
              folder_arrow = true,
            },
          },
        },
        actions = {
          open_file = {
            quit_on_open = false,
          },
        },
      })

      vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { noremap = true, silent = true })
    end,
  },
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- Modern commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },

  -- Auto-close brackets and quotes
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({})
      -- Integrate with nvim-cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Visual indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = {
          char = "│",
        },
        scope = {
          enabled = false,
        },
      })
    end,
  },

  -- Utility
  { "tpope/vim-eunuch" },

  -- GitHub Copilot
  { "github/copilot.vim" },

  -- Native LSP, completion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- Treesitter for modern syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          "javascript",
          "typescript",
          "tsx",
          "json",
          "css",
          "html",
          "lua",
          "vim",
          "vimdoc",
          "graphql",
          "rust",
          "c_sharp",
          "gdscript",
          "markdown",
          "markdown_inline",
          "query",
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = {
          enable = true,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<S-CR>",
            node_decremental = "<BS>",
          },
        },
      })
    end,
  },

  -- Notification popup with animations
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({
        stages = "slide",  -- Animation style: "fade", "slide", "fade_in_slide_out", "static"
        timeout = 3000,    -- Default timeout in milliseconds
        background_colour = "#000000",
        icons = {
          ERROR = "",
          WARN = "",
          INFO = "",
          DEBUG = "",
          TRACE = "✎",
        },
        render = "default", -- Render style: "default", "minimal", "simple", "compact"
        max_width = 50,
        max_height = 10,
        minimum_width = 50,
        top_down = true,   -- Notifications start from top
      })
      
      -- Set nvim-notify as the default notification handler
      vim.notify = notify
    end,
  },

  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      input = {},
      picker = {
        layout = {
          preset = "default",
          layout = {
            width = 0.9,
            height = 0.9,
          },
        },
        win = {
          input = {
            keys = {
              ["<Tab>"] = { "list_down", mode = { "i", "n" } },
              ["<S-Tab>"] = { "list_up", mode = { "i", "n" } },
            },
          },
        },
      },
      terminal = {}
    }
  },

  {
    "NickvanDyke/opencode.nvim",
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition".
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      -- Recommended/example keymaps.
      vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode" })
      vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
      vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

      vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { expr = true, desc = "Add range to opencode" })
      vim.keymap.set("n",          "goo", function() return require("opencode").operator("@this ") .. "_" end, { expr = true, desc = "Add line to opencode" })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "opencode half page up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "opencode half page down" })

      -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o".
      vim.keymap.set("n", "+", "<C-a>", { desc = "Increment", noremap = true })
      vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement", noremap = true })
    end,
  }
}, {
  rocks = { enabled = false }
})

local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<c-Space>"] = cmp.mapping.complete(),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
  },
})

-- Keymap helper
local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Setup Mason first
require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = { "vtsls", "biome", "rust_analyzer", "omnisharp" },
})

-- Get capabilities from nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Format on save autocmd helper
local function setup_format_on_save(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = false })
    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = augroup,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, timeout_ms = 2000 })
      end,
    })
  end
end


--------------------------------------------------------------------------------
-- LSP CONFIGURATION (Nvim 0.11/0.12 + lspconfig)
--------------------------------------------------------------------------------

-- Require lspconfig so it registers its default configurations into vim.lsp.config
require("lspconfig")

-- 1. TypeScript Language Server (VTSLS)
local vtsls = vim.lsp.config.vtsls
vtsls.capabilities = capabilities
vtsls.settings = {
  typescript = { tsserver = { enableProjectDiagnostics = false } },
  javascript = { tsserver = { enableProjectDiagnostics = false } },
}
vtsls.on_attach = function(client, bufnr)
  -- Disable vtsls formatting in favor of Biome
  client.server_capabilities.documentFormattingProvider = false
  client.server_capabilities.documentRangeFormattingProvider = false
end
vim.lsp.enable("vtsls")


-- 2. Biome LSP (formatter + linter)
local biome = vim.lsp.config.biome
biome.capabilities = capabilities
biome.on_attach = function(client, bufnr)
  setup_format_on_save(client, bufnr)
end
vim.lsp.enable("biome")


-- 3. Rust Analyzer
local rust_analyzer = vim.lsp.config.rust_analyzer
rust_analyzer.capabilities = capabilities
rust_analyzer.on_attach = function(client, bufnr)
  setup_format_on_save(client, bufnr)
end
rust_analyzer.settings = {
  ["rust-analyzer"] = {
    cargo = { allFeatures = true },
    check = { command = "clippy" },
    procMacro = { enable = true },
  },
}
vim.lsp.enable("rust_analyzer")


-- 4. OmniSharp (C#)
local omnisharp = vim.lsp.config.omnisharp
omnisharp.capabilities = capabilities
omnisharp.on_attach = function(client, bufnr)
  setup_format_on_save(client, bufnr)
end
vim.lsp.enable("omnisharp")


-- 5. Godot GDScript
local gdscript = vim.lsp.config.gdscript
gdscript.capabilities = capabilities
gdscript.cmd = { "godot", "--headless", "--language-server" }
gdscript.filetypes = { "gd", "gdscript", "gdshader", "gdshaderinc" }
gdscript.root_dir = function(fname)
  return vim.fs.root(fname, { "project.godot" })
end
gdscript.on_attach = function(client, bufnr)
  setup_format_on_save(client, bufnr)
end
vim.lsp.enable("gdscript")

-- Custom Biome Lint command
local function run_biome_lint()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Biome lint: no file name for current buffer", vim.log.levels.WARN)
    return
  end

  local root = vim.fs.root(file, { "biome.json", "biome.jsonc", "package.json" }) or vim.fn.fnamemodify(file, ":h")
  local local_biome = root .. "/node_modules/.bin/biome"
  local biome_bin = vim.uv.fs_stat(local_biome) and local_biome or "biome"

  vim.system({ biome_bin, "check", file, "--write" }, { text = true, cwd = root }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("Biome lint: clean", vim.log.levels.INFO)
        return
      end

      local output = (result.stdout or "") .. (result.stderr or "")
      if output == "" then output = "Biome lint failed" end
      vim.notify(output, vim.log.levels.ERROR)
    end)
  end)
end

vim.api.nvim_create_user_command("Lint", run_biome_lint, {})

-- VTSLS warmer (simplified for native LSP)
local vtsls_warmed = false
local function warm_vtsls()
  if vtsls_warmed then return end
  vtsls_warmed = true

  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].bufhidden = "hide"
  vim.bo[bufnr].filetype = "typescript"
end

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(warm_vtsls, 50)
  end,
})

--------------------------------------------------------------------------------
-- KEYMAPS AND UI
--------------------------------------------------------------------------------

-- Native LSP bindings replacing coc mappings
keymap("n", "gd", function()
  require("snacks").picker.lsp_definitions({
    unique_lines = true,
    transform = function(item, ctx)
      local file = item.file or item.text
      if not file or not item.pos then
        return
      end
      ctx.meta.seen = ctx.meta.seen or {}
      local end_pos = item.end_pos or { 0, 0 }
      local key = table.concat({
        file,
        item.pos[1],
        item.pos[2],
        end_pos[1],
        end_pos[2],
      }, ":")
      if ctx.meta.seen[key] then
        return false
      end
      ctx.meta.seen[key] = true
    end,
  })
end, opts)
keymap("n", "gt", vim.lsp.buf.type_definition, opts)
keymap("n", "gi", vim.lsp.buf.implementation, opts)
keymap("n", "gr", function() 
  require("snacks").picker.lsp_references() 
end, opts)

keymap("n", "<leader>l", "<cmd>Lint<cr>", opts)

-- Bookmark command (assuming you have a Bookmark plugin configured)
keymap("n", "<leader>b", "<cmd>Bookmark<cr>", opts)

-- Snacks picker bindings
-- File pickers
keymap("n", "<Leader>ff", function()
  require("snacks").picker.files()
end, opts)
keymap("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, opts)
keymap("n", "<leader>fr", function()
  require("snacks").picker.recent()
end, opts)

-- Grep pickers
keymap("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, opts)
keymap("n", "<leader>fw", function()
  require("snacks").picker.grep_word()
end, opts)

-- LSP & Code Navigation
keymap("n", "<leader>ss", function()
  require("snacks").picker.lsp_symbols()
end, opts)
keymap("n", "<leader>sS", function()
  require("snacks").picker.lsp_workspace_symbols()
end, opts)
keymap("n", "<leader>sd", function()
  require("snacks").picker.diagnostics()
end, opts)
keymap("n", "<leader>sD", function()
  require("snacks").picker.diagnostics_buffer()
end, opts)

-- Useful utilities
keymap("n", "<leader>sr", function()
  require("snacks").picker.resume()
end, opts)
keymap("n", "<leader>su", function()
  require("snacks").picker.undo()
end, opts)
keymap("n", "<leader>sh", function()
  require("snacks").picker.help()
end, opts)
keymap("n", "<leader>sk", function()
  require("snacks").picker.keymaps()
end, opts)
keymap("n", "<leader>sm", function()
  require("snacks").picker.marks()
end, opts)
keymap("n", "<leader>sc", function()
  require("snacks").picker.commands()
end, opts)
keymap("n", "<leader>sj", function()
  require("snacks").picker.jumps()
end, opts)
keymap("n", "<leader>sn", function()
  require("snacks").picker.notifications()
end, opts)
keymap("n", "<leader>sq", function()
  require("snacks").picker.qflist()
end, opts)
keymap("n", "<leader>sl", function()
  require("snacks").picker.loclist()
end, opts)

-- Git pickers
keymap("n", "<leader>fc", function()
  require("snacks").picker.git_status()
end, opts)
keymap("n", "<leader>gb", function()
  require("snacks").picker.git_branches()
end, opts)
keymap("n", "<leader>gl", function()
  require("snacks").picker.git_log()
end, opts)
keymap("n", "<leader>gL", function()
  require("snacks").picker.git_log_line()
end, opts)
keymap("n", "<leader>gf", function()
  require("snacks").picker.git_log_file()
end, opts)
keymap("n", "<leader>gd", function()
  require("snacks").picker.git_diff()
end, opts)

-- Buffer navigation (barbar)
keymap("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
keymap("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)
keymap("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)
keymap("n", "<A-s-c>", "<Cmd>BufferRestore<CR>", opts)

-- Clipboard yank/paste
keymap("n", "<Leader>y", '"*y', { noremap = true })
keymap("n", "<Leader>p", '"*p', { noremap = true })

-- Copilot accept
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<C-c>", "copilot#Accept('<CR>')", { noremap = true, silent = true, expr=true, replace_keycodes = false })

keymap("n", "<leader>n", "<cmd>NvimTreeFindFile<CR>", opts)

-- Love that theme. it's beautiful.
vim.cmd.colorscheme("catppuccin-mocha")

-- Edge theme style
vim.g.edge_style = "neon"

vim.api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
  {
    pattern = "*",
    callback = function()
      local mode = vim.fn.mode()
      local cmdwin = vim.fn.getcmdwintype()
      if not mode:match("c") and not mode:match("r.?") and not mode:match("!") and not mode:match("t") and cmdwin == "" then
        vim.cmd("checktime")
      end
    end
  }
)

-- Notify when a file has changed on disk and reload buffer
vim.api.nvim_create_autocmd(
  "FileChangedShellPost",
  {
    pattern = "*",
    callback = function()
      vim.api.nvim_echo({{"File changed on disk. Buffer reloaded.", "WarningMsg"}}, false, {})
    end
  }
)

vim.o.updatetime = 250  -- Faster CursorHold triggering

vim.cmd([[
  autocmd CursorHold * lua vim.diagnostic.open_float(nil, { focusable = false })
]])

vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { noremap = true, silent = true })

vim.api.nvim_set_hl(0, "NvimTreeNormal",   { bg = "#1A1922" })
vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "#1A1922" })
vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "#1A1922" })
vim.api.nvim_set_hl(0, "SnacksInputNormal", { bg = "#1A1922" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "#000000" }) -
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "NvimTreeNormal",   { bg = "#1A1922" })
    vim.api.nvim_set_hl(0, "NvimTreeNormalNC", { bg = "#1A1922" })
    vim.api.nvim_set_hl(0, "SnacksPickerNormal", { bg = "#1A1922" })
    vim.api.nvim_set_hl(0, "SnacksInputNormal", { bg = "#1A1922" })
  end,
})

vim.keymap.set("n", "<leader>ch", function()
  for _, win in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end, { noremap = true, silent = true })
