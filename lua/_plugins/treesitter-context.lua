return {
  'nvim-treesitter/nvim-treesitter-context',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },

  event = 'BufReadPost',

  keys = {
    { mode = 'n', '<leader>tc', ':TSContextToggle<CR>' },
    {
      mode = 'n',
      '<leader>[c',
      function() require("treesitter-context").go_to_context(vim.v.count1) end,
    },
  },
  opts = {
    enable = true,
    mode = 'cursor',
    separator = '―',
    max_lines = 6,
    min_window_height = 20,
  },
}
