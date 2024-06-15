local plugin = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  -- commit = '08aabb145f93ed1dd607ce8e2dcd52d356822300',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/playground',
    'windwp/nvim-ts-autotag',
  },
}

local function get_ts_config()
  return {
    ensure_installed = 'all',

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'markdown' },
    },

    indent = {
      enable = true,
    },

    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<localleader><CR>',
        scope_incremental = '<C-TAB>',
        node_incremental = '<TAB>',
        node_decremental = '<S-TAB>',
      },
    },

    autotag = {
      enable = true,
    },

    textobjects = {
      enable = true,
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['aa'] = '@parameter.outer',
          ['ia'] = '@parameter.inner',
        },
      },
      swap = {
        enable = true,
        swap_next = {
          ['<C-l>'] = '@parameter.inner',
        },
        swap_previous = {
          ['<C-h>'] = '@parameter.inner',
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_previous_start = {
          ['[['] = '@function.outer',
        },
        goto_next_start = {
          [']]'] = '@function.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
          ['<leader>dt'] = '@function.outer',
        },
      },
    },
  }
end

function plugin.config() require('nvim-treesitter.configs').setup(get_ts_config()) end

return plugin
