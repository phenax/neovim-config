local utils = require 'utils'
local nmap = utils.nmap
local nmap_silent = utils.nmap_silent

local fs = {}

function fs.plugins(use)
  use 'djoshea/vim-autoread'
  use {
    'kyazdani42/nvim-tree.lua',
    -- commit = '71122d798482e30c599d78aa7ae4a756c6e81a79',
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
end

function fs.configure()
  -- File tree
  nmap_silent('<localleader>nn', ':NvimTreeToggle<CR>')
  nmap_silent('<localleader>nf', ':NvimTreeFindFileToggle<CR>')

  -- g.nvim_tree_auto_close = 1
  -- g.nvim_tree_width = 40

  require('nvim-tree').setup({
    create_in_closed_folder = true,
    hijack_cursor = true,
    view = {
      adaptive_size = true,
      centralize_selection = true,
      -- float = {
      --   enable = true,
      --   open_win_config = {
      --     border = 'single',
      --     height = 40,
      --   },
      -- },
      mappings = {
        custom_only = true,
        list = {
          { key = "R",              action = "refresh" },
          { key = "q",              action = "close" },

          { key = "<CR>",           action = "edit" },
          { key = "h",              action = "close_node" },
          { key = "l",              action = "edit" },

          { key = "<C-h>",          action = "dir_up" },
          { key = "<C-l>",          action = "cd" },

          { key = "<C-v>",          action = "vsplit" },
          { key = "<C-s>",          action = "split" },

          { key = "<",              action = "prev_sibling" },
          { key = ">",              action = "next_sibling" },

          { key = "<Tab>",          action = "preview" },
          { key = ".",              action = "toggle_dotfiles" },

          { key = "a",              action = "create" },
          { key = "d",              action = "remove" },
          { key = "r",              action = "rename" },

          { key = "x",              action = "cut" },
          { key = "y",              action = "copy" },
          { key = "p",              action = "paste" },
          { key = "Y",              action = "copy_path" },
        },
      },
    },
    renderer = {
      group_empty = true,
      add_trailing = true,
      highlight_git = true,
      indent_width = 2,
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  })

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

  -- Set buffer file type
  nmap_silent('<leader>cf', ':Telescope filetypes<cr>')

  exec [[autocmd StdinReadPre * let s:std_in=1autocmd StdinReadPre * let s:std_in=1]]
  exec [[autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'bd' | endif]]
end

return fs
