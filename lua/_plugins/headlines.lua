return {
  'lukas-reineke/headlines.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  ft = { 'norg', 'markdown' },

  config = function()
    require('headlines').setup({
      markdown = {
        headline_highlights = { 'Headline' },
        dash_highlight = 'Dash',
        dash_string = '-',
        doubledash_highlight = 'DoubleDash',
        doubledash_string = '=',
        -- quote_highlight = false,
        fat_headlines = false,
        bullets = false,
      },
      norg = {
        headline_highlights = { 'Headline' },
        codeblock_highlight = false,
        dash_highlight = 'Dash',
        dash_string = '-',
        doubledash_highlight = 'DoubleDash',
        doubledash_string = '=',
        quote_highlight = false,
        fat_headlines = false,
        bullets = false,
      },
    })
  end,
}
