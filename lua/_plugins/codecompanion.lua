return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'hrsh7th/nvim-cmp', -- Optional: For using slash commands and variables in the chat buffer
  },
  opts = {},
  keys = {
    {
      mode = 'n',
      '<a-c>c',
      '<cmd>CodeCompanionChat Toggle<cr>',
    },
    {
      mode = { 'n', 'x' },
      '<a-c>a',
      '<cmd>CodeCompanionChat Add<cr>',
    },
    {
      mode = { 'n', 'x' },
      '<a-c>e',
      '<cmd>CodeCompanion /explain',
    },
  },
}
