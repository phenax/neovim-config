local M = {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
}

function M.config()
  require('aerial').setup({
    disable_max_lines = 30000,
  })
  vim.keymap.set('n', '<localleader>ns', ':AerialToggle right<cr>')
  vim.keymap.set('n', '<localleader>nt', ':AerialNavToggle<cr>')
end

return M
