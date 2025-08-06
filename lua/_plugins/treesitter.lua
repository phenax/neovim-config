local plugin = {}

function plugin.config()
  require('nvim-treesitter.configs').setup {
    ensure_installed = 'all',
    ignore_install = { 'ipkg' }, -- Was breaking during unpacking

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
          ['<C-l>'] = '@parameter.inner'
        },
        swap_previous = {
          ['<C-h>'] = '@parameter.inner'
        },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_previous_start = {
          ['[['] = '@function.outer',
          ['[a'] = '@parameter.outer',
        },
        goto_next_start = {
          [']]'] = '@function.outer',
          [']a'] = '@parameter.outer',
        },
      },
      lsp_interop = {
        enable = true,
        border = 'none',
        peek_definition_code = {
          ['<leader>dt'] = '@function.outer'
        },
      },
    },
  }
end

return plugin
