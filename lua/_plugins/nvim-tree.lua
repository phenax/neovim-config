local plugin = {
  'kyazdani42/nvim-tree.lua',

  keys = {
    { '<localleader>nn', ':NvimTreeToggle<CR>', mode = 'n' },
    { '<localleader>nf', ':NvimTreeFindFileToggle<CR>', mode = 'n' },
  },
}

local config = {}

function plugin.config()
  -- vim.keymap.set('n', '<localleader>nn', ':NvimTreeToggle<CR>')
  -- vim.keymap.set('n', '<localleader>nf', ':NvimTreeFindFileToggle<CR>')

  require('nvim-tree').setup({
    hijack_cursor = true,
    on_attach = config.nvim_tree_on_attach,
    sync_root_with_cwd = false,
    view = {
      centralize_selection = true,
    },
    renderer = {
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
      use_system_clipboard = true,
      open_file = {
        quit_on_open = true,
        window_picker = {
          enable = false,
        },
      },
      change_dir = {
        global = true,
      },
    },
  })

  vim.cmd [[autocmd StdinReadPre * let s:std_in=1autocmd StdinReadPre * let s:std_in=1]]
  vim.cmd [[autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'bd' | endif]]
end

function config.nvim_tree_on_attach(bufnr)
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

return plugin
