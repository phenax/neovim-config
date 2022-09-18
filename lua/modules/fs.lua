local utils = require 'utils'
local nmap = utils.nmap
local nmap_silent = utils.nmap_silent

local fs = {}

function fs.plugins(use)
  use 'djoshea/vim-autoread'
  use { 'kyazdani42/nvim-tree.lua', commit = '71122d798482e30c599d78aa7ae4a756c6e81a79' }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
end

function fs.configure()
  -- File tree
  nmap_silent('<localleader>nn', ':NvimTreeToggle<CR>')
  nmap_silent('<localleader>nr', ':NvimTreeRefresh<CR>')
  nmap_silent('<localleader>nf', ':NvimTreeFindFile<CR>')
  g.nvim_tree_git_hl = 1
  g.nvim_tree_lsp_diagnostics = 1
  g.nvim_tree_add_trailing = 1
  g.nvim_tree_auto_close = 1
  g.nvim_tree_width = 40

  local tree_cmd = require'nvim-tree.config'.nvim_tree_callback
  vim.g.nvim_tree_bindings = {
    { key = "R",              cb = tree_cmd("refresh") },
    { key = "q",              cb = tree_cmd("close") },

    { key = "<CR>",           cb = tree_cmd("edit") },
    { key = "h",              cb = tree_cmd("close_node") },
    { key = "l",              cb = tree_cmd("edit") },

    { key = "<C-h>",          cb = tree_cmd("dir_up") },
    { key = "<C-l>",          cb = tree_cmd("cd") },

    { key = "<C-v>",          cb = tree_cmd("vsplit") },
    { key = "<C-s>",          cb = tree_cmd("split") },

    { key = "<",              cb = tree_cmd("prev_sibling") },
    { key = ">",              cb = tree_cmd("next_sibling") },

    { key = "<Tab>",          cb = tree_cmd("preview") },
    { key = ".",              cb = tree_cmd("toggle_ignored") },

    { key = "a",              cb = tree_cmd("create") },
    { key = "d",              cb = tree_cmd("remove") },
    { key = "r",              cb = tree_cmd("rename") },

    { key = "x",              cb = tree_cmd("cut") },
    { key = "y",              cb = tree_cmd("copy") },
    { key = "p",              cb = tree_cmd("paste") },
    { key = "Y",              cb = tree_cmd("copy_path") },
  }
  -- g.nvim_tree_gitignore = 1
  -- g.nvim_tree_auto_open = 1

  require('telescope').setup {
    defaults = {
      prompt_prefix = "λ ",
      sorting_strategy = "ascending",
      layout_config = {
        width = 0.8,
        prompt_position = "top",
        preview_cutoff = 120,
      },
      color_devicons = true,
      use_less = true,
    }
  }
  -- Resume last search
  nmap('<leader>tr', ':Telescope resume<CR>')

  -- Fuzzy file finder
  if utils.fexists('.git') then
    nmap_silent('<leader>f', ':Telescope git_files<cr>')
  else
    nmap_silent('<leader>f', ':Telescope find_files<cr>')
  end

  -- Global content search
  nmap_silent('<c-f>', ':Telescope live_grep<cr>')
  nmap_silent('<leader>mm', ':Telescope marks<cr>')

  -- Tag navigation
  nmap_silent('<c-c>', ':Telescope tags<cr>')

  -- Set buffer file type
  nmap_silent('<leader>cf', ':Telescope filetypes<cr>')

  exec [[autocmd StdinReadPre * let s:std_in=1autocmd StdinReadPre * let s:std_in=1]]
  exec [[autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'bd' | endif]]
end

return fs
