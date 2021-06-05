local utils = require 'utils'
local nmap = utils.nmap
local nmap_silent = utils.nmap_silent

local fs = {}

function fs.plugins(use)
  -- use 'junegunn/fzf'
  -- use 'junegunn/fzf.vim'
  use 'djoshea/vim-autoread'
  use 'kyazdani42/nvim-tree.lua'
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
end

function fs.configure()
  -- File tree
  nmap_silent('<localleader>nn', ':NvimTreeToggle<CR>')
  nmap_silent('<localleader>nr', ':NvimTreeRefresh<CR>')
  g.nvim_tree_git_hl = 1
  g.nvim_tree_lsp_diagnostics = 1
  g.nvim_tree_add_trailing = 1
  g.nvim_tree_auto_close = 1
  g.nvim_tree_width = 40

  local tree_cmd = require'nvim-tree.config'.nvim_tree_callback
  vim.g.nvim_tree_bindings = {
    ["R"]              = tree_cmd("refresh"),
    ["q"]              = ":q<CR>", -- tree_cmd("close")

    ["<CR>"]           = tree_cmd("edit"),
    ["h"]              = tree_cmd("close_node"),
    ["l"]              = tree_cmd("edit"),

    ["<C-h>"]          = tree_cmd("dir_up"),
    ["<C-l>"]          = tree_cmd("cd"),

    ["<C-v>"]          = tree_cmd("vsplit"),
    ["<C-s>"]          = tree_cmd("split"),

    ["<"]              = tree_cmd("prev_sibling"),
    [">"]              = tree_cmd("next_sibling"),

    ["<Tab>"]          = tree_cmd("preview"),
    ["."]              = tree_cmd("toggle_ignored"),

    ["a"]              = tree_cmd("create"),
    ["d"]              = tree_cmd("remove"),
    ["r"]              = tree_cmd("rename"),

    ["x"]              = tree_cmd("cut"),
    ["y"]              = tree_cmd("copy"),
    ["p"]              = tree_cmd("paste"),
    ["Y"]              = tree_cmd("copy_path"),
  }
  -- g.nvim_tree_gitignore = 1
  -- g.nvim_tree_auto_open = 1

  require('telescope').setup {
    defaults = {
      prompt_position = "top",
      prompt_prefix = "λ ",
      sorting_strategy = "ascending",
      width = 0.3,
      preview_cutoff = 120,
      color_devicons = true,
      use_less = true,
    }
  }

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
  
  exec [[autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif]]
  exec [[autocmd FileType coc-explorer setlocal nolist]]
end

return fs
