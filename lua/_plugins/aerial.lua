local M = {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<localleader>ns', ':AerialToggle right<cr>', mode = 'n' },
    { '<localleader>nt', ':AerialNavToggle<cr>',    mode = 'n' },
  },
}

function M.config()
  require('aerial').setup({
    disable_max_lines = 30000,
  })
  -- vim.keymap.set('n', '<localleader>ns', ':AerialToggle right<cr>')
  -- vim.keymap.set('n', '<localleader>nt', ':AerialNavToggle<cr>')
end

return M
