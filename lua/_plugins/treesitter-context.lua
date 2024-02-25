return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },

  event = 'BufReadPost',

  keys = {
    { mode = 'n', '<leader>tc', ':TSContextToggle<CR>' },
  },
  opts = {
    enable = true,
    mode = 'cursor',
    separator = '―',
    max_lines = 6,
    min_window_height = 20,
  },
}
