local M = {
  'folke/trouble.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
}

function M.config()
  require('trouble').setup {
    mode = 'workspace_diagnostics',
    position = 'bottom',
    height = 16,
  }
  vim.keymap.set('n', '<leader>xx', ':TroubleToggle workspace_diagnostics<cr>')
end

return M
