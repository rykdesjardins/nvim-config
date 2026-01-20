-- Neovim configuration file with lazy.nvim plugin manager
-- Also configures neovide settings, LSP, Telescope, Nvim Tree.
--
-- Requires a patched version of Comic Mono from nerd fonts :
--   https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/ComicShannsMono
--
-- Otherwise requires the new typescript server (ts_ls) and biome installed via npm.

vim.g.mapleader = "#"
vim.opt.clipboard = "unnamedplus"

if vim.g.neovide then
  vim.o.guifont = "Comic Mono:h12"
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
vim.opt.laststatus = 2

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

-- Autocmd for typescriptreact files
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.tsx", "*.jsx" },
  command = "set filetype=typescript.tsx",
})

-- Global variables, might remove since not using nerdtree anymore
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
  { "nvim-lua/plenary.nvim" }, -- Required by none-ls
  { "nvimtools/none-ls.nvim", 
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
    local null_ls = require("null-ls")
    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.biome,
      },
      on_attach = function(client, bufnr)
        -- Format on save for null-ls (Biome)
        if client.supports_method("textDocument/formatting") then
          local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ bufnr = bufnr })
            end,
          })
        end
      end,
    })
  end },

  -- Language syntax / highlighting
  { "pangloss/vim-javascript" },
  { "leafgarland/typescript-vim" },
  { "maxmellon/vim-jsx-pretty" },
  { "peitalin/vim-jsx-typescript" },
  { "jparise/vim-graphql" },

  -- Git integration
  { "lewis6991/gitsigns.nvim" },

  -- Statusline / UI
  { "itchyny/lightline.vim" },
  { "romgrk/barbar.nvim" },  -- Bufferline alternative

  -- Editorconfig
  { "editorconfig/editorconfig-vim" },

  -- Icons and sidebar file explorer (nvim-tree replaced NERDTree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        -- Example config; adjust as you wish:
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

  -- Commenting
  { "scrooloose/nerdcommenter" },

  -- Utility
  { "tpope/vim-eunuch" }, -- :Rename, :Delete, etc.

  -- GitHub Copilot
  { "github/copilot.vim" },

  -- Native LSP, completion, formatting
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", config = true },
  { "williamboman/mason-lspconfig.nvim", config = true },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "jose-elias-alvarez/null-ls.nvim" },

  -- Treesitter (highly recommended)
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  {
    "NickvanDyke/opencode.nvim",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { 
        input = {}, 
        picker = {
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
      } },
    },
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

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require("lspconfig") 
lspconfig["ts_ls"].setup({})

require("mason").setup()
--require("mason-lspconfig").setup({
--  ensure_installed = { "typescript-language-server" },
--})

-- Native LSP bindings replacing coc mappings
keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "gt", vim.lsp.buf.type_definition, opts)
keymap("n", "gi", vim.lsp.buf.implementation, opts)
-- keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "gr", function() 
  require("snacks").picker.lsp_references() 
end, opts)

-- Bookmark command (assuming you have a Bookmark plugin configured)
keymap("n", "<leader>b", "<cmd>Bookmark<cr>", opts)

-- Snacks picker bindings
keymap("n", "<leader>fr", function()
  require("snacks").picker.resume()
end, opts)
keymap("n", "<leader>fb", function()
  require("snacks").picker.files({ cwd = vim.fn.expand("%:p:h") })
end, opts)
keymap("n", "<leader>fh", function()
  require("snacks").picker.help()
end, opts)
keymap("n", "<Leader>ff", function()
  require("snacks").picker.files()
end, { noremap = true, silent = true })
keymap("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { noremap = true, silent = true })
keymap("n", "<leader>fc", function()
  require("snacks").picker.git_status()
end, { noremap = true, silent = true })

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


