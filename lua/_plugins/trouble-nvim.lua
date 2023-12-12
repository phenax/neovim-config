return {
  'folke/trouble.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
  },
  keys = {
    { mode = 'n', '<leader>xx', ':TroubleToggle workspace_diagnostics<cr>' },
  },

  opts = {
    mode = 'workspace_diagnostics',
    position = 'bottom',
    height = 16,
  },
}
