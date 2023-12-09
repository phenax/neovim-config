local M = {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  commit = '08aabb145f93ed1dd607ce8e2dcd52d356822300',
  dependencies = {
    'nvim-treesitter/nvim-treesitter-textobjects',
    'nvim-treesitter/nvim-treesitter-context',
    'nvim-treesitter/playground',
    'windwp/nvim-ts-autotag',
  },
}

local function get_ts_config()
  return {
    ensure_installed = 'all',

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    indent = {
      enable = true
    },

    incremental_selection = {
	    enable = true,
	    keymaps = {
	      init_selection = '<localleader><CR>',
	      scope_incremental = '<localleader><CR>',
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
        swap = {
          enable = true,
          swap_next = {
            ['<M-n>'] = '@parameter.inner',
          },
          swap_previous = {
            ['<M-p>'] = '@parameter.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ['<leader>rn'] = '@function.outer',
          },
          goto_previous_start = {
            ['<leader>rp'] = '@function.outer',
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
    },
  }
end

function M.config()
  require'nvim-treesitter.configs'.setup(get_ts_config())

  -- TS context
  require'treesitter-context'.setup({
    enable = true,
    mode = 'topline',
    separator = '―',
    max_lines = 10,
  })
  vim.keymap.set('n', '<leader>tc', ':TSContextToggle<CR>')
  vim.keymap.set('n', '<localleader>ck', function()
    require('treesitter-context').go_to_context()
  end, { silent = true })
end

return M
