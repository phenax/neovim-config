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

local function nvim_tree_on_attach(bufnr)
  local api = require('nvim-tree.api')

  local function add_key(key, action, desc)
    local opts = { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    vim.keymap.set('n', key, action, opts)
  end

  add_key('R',      api.tree.reload, 'Refresh')
  add_key('q',      api.tree.close, 'Close')
  add_key('?',      api.tree.toggle_help, 'Help')
  add_key('<C-e>',  api.node.run.system, 'Run System')

  add_key('h',      api.node.navigate.parent_close, 'Close Directory')
  add_key('l',      api.node.open.edit, 'Open')
  add_key('<C-h>',  api.tree.change_root_to_parent, 'Up')
  add_key('<C-l>',  api.tree.change_root_to_node, 'CD')
  add_key('<',      api.node.navigate.sibling.prev, 'Previous Sibling')
  add_key('>',      api.node.navigate.sibling.next, 'Next Sibling')

  add_key('<CR>',   api.node.open.edit, 'Open')
  add_key('<C-v>',  api.node.open.vertical, 'Open: Vertical Split')
  add_key('<C-s>',  api.node.open.horizontal, 'Open: Horizontal Split')
  add_key('<Tab>',  api.node.open.preview, 'Open Preview')

  add_key('.',      api.tree.toggle_hidden_filter, 'Toggle Dotfiles')

  add_key('a',      api.fs.create, 'Create')
  add_key('d',      api.fs.remove, 'Delete')
  add_key('r',      api.fs.rename, 'Rename')
  add_key('x',      api.fs.cut, 'Cut')
  add_key('y',      api.fs.copy.node, 'Copy')
  add_key('p',      api.fs.paste, 'Paste')
  add_key('Y',      api.fs.copy.relative_path, 'Copy Relative Path')
end

function fs.configure()
  -- File tree
  nmap_silent('<localleader>nn', ':NvimTreeToggle<CR>')
  nmap_silent('<localleader>nf', ':NvimTreeFindFileToggle<CR>')

  -- g.nvim_tree_auto_close = 1
  -- g.nvim_tree_width = 40

  require('nvim-tree').setup({
    hijack_cursor = true,
    on_attach = nvim_tree_on_attach,
    view = {
      centralize_selection = true,
    },
    renderer = {
      -- group_empty = true,
      add_trailing = true,
      highlight_git = true,
      highlight_opened_files = 'icon',
      indent_width = 2,
      indent_markers = {
        enable = true,
        inline_arrows = true,
      },
    },
    actions = {
      open_file = {
        quit_on_open = true,
      },
    },
  })

  local actions = require('telescope.actions')
  local function open_and_resume(prompt_bufnr)
    actions.select_default(prompt_bufnr)
    require('telescope.builtin').resume()
  end

  require('telescope').setup {
    defaults = {
      prompt_prefix = ' λ ',
      sorting_strategy = 'ascending',
      layout_config = {
        width = 0.8,
        prompt_position = 'top',
        preview_cutoff = 120,
      },
      color_devicons = true,
      use_less = true,

      mappings = {
        n = {
          ['<C-d>'] = actions.delete_buffer,
          ['<C-o>'] = open_and_resume,
        },
        i = {
          ['<C-d>'] = actions.delete_buffer,
          ['<C-o>'] = open_and_resume,
          ['<C-h>'] = 'which_key',
        }
      },
    },
  }
  -- Resume last search
  nmap('<leader>tr', ':Telescope resume<CR>')

  -- Fuzzy file finder
  if utils.fexists('.git') then
    nmap_silent('<leader>f', ':Telescope git_files show_untracked=true<cr>')
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
