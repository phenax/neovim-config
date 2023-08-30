local M = {}

function M.setup()
  require('trouble').setup {
    mode = 'workspace_diagnostics',
    position = 'bottom',
    height = 16,
  }
  vim.keymap.set('n', '<leader>xx', ':TroubleToggle workspace_diagnostics<cr>')
end

return M
