return {
  'https://git.sr.ht/~whynothugo/lsp_lines.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>dv', function() require('lsp_lines').toggle() end, mode = 'n' },
  },
  config = function()
    require('lsp_lines').setup {}
    vim.diagnostic.config { virtual_lines = false }
  end,
}
