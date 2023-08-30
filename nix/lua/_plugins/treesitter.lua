local M = {
  treesitter_runtime_dir = vim.fn.expand("~/.local/share/nvim-flake/treesitter/parsers"),
}

function M.setup()
  vim.opt.runtimepath:append(M.treesitter_runtime_dir)

  require'nvim-treesitter.configs'.setup(M.get_ts_config())

  -- TS context
  require'treesitter-context'.setup({
    enable = true,
    mode = 'cursor',
    separator = '―',
  })
  vim.keymap.set('n', '<leader>tc', ':TSContextToggle<CR>')
end

function M.get_ts_config()
  return {
    ensure_installed = "all",
    parser_install_dir = M.treesitter_runtime_dir,
    auto_install = false,

    highlight = { enable = true },
    indent = { enable = true },

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
        swap = { enable = true },
        move = { enable = true, set_jumps = true },
        lsp_interop = {
          enable = true,
          border = 'none',
          peek_definition_code = { ["<leader>dt"] = "@function.outer" },
        },
      },
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

    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = 2000,
    }
  }
end

return M
