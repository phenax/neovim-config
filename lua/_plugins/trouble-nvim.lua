local M = {
  'folke/trouble.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { mode = 'n', '<leader>xx', ':TroubleToggle workspace_diagnostics<cr>' },
  },
}

function M.config()
  require('trouble').setup {
    mode = 'workspace_diagnostics',
    position = 'bottom',
    height = 16,
  }
end

return M
