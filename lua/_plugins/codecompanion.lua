return {
  'olimorris/codecompanion.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'hrsh7th/nvim-cmp', -- Optional: For using slash commands and variables in the chat buffer
  },

  keys = {
    { mode = { 'n', 'x' }, '<a-c>c', '<cmd>CodeCompanionChat Toggle<cr>' },
    { mode = { 'n', 'x' }, '<a-c>a', '<cmd>CodeCompanionChat Add<cr>' },
    { mode = { 'n', 'x' }, '<a-c>e', '<cmd>CodeCompanion /explain<cr>' },
    { mode = 'n',          '<a-c>p', '<cmd>CodeCompanionActions<cr>' },
  },

  opts = {
    strategies = {
      chat = {
        keymaps = {
          close = { modes = { n = '<localleader>q', i = '<c-q>' } },
        },
      },
    },
    prompt_library = {
      ['Lorem Ipsum'] = {
        strategy = 'inline',
        description = 'Generate boilerplate text content',
        prompts = {
          { role = 'system', content = 'You are a content writer' },
          {
            role = 'user',
            content =
            'Please generate some random boilerplate text content to fill at least 2 paragraphs. Return just the text content',
          },
        },
      },
    },
  },
}
