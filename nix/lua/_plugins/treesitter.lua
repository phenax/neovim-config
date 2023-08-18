local M = {}

function M.setup()
  require'nvim-treesitter.configs'.setup(M.get_ts_config())

  -- TS context
  require'treesitter-context'.setup({
    enable = true,
    mode = 'cursor',
    separator = '―',
  })
  vim.keymaps.set('n', '<leader>tc', ':TSContextToggle<CR>')
end

function M.get_ts_config()
  return {
    ensure_installed = "all",

    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    indent = {
      enable = true
    },

    textobjects = {
      enable = true,
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
        swap = {
          enable = true,
          swap_next = {
            ["<M-n>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<M-p>"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["<leader>rn"] = "@function.outer",
          },
          goto_previous_start = {
            ["<leader>rp"] = "@function.outer",
          },
        },
        lsp_interop = {
          enable = true,
          border = 'none',
          peek_definition_code = {
            ["<leader>dt"] = "@function.outer",
          },
        },
      },
    },

    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 2000,
    }
  }
end

return M
