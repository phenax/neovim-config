local plugin = {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl'
}

function plugin.config()
  -- Indent blankline
  require('ibl').setup {
    indent = {
      highlight = { 'CursorColumn', 'Comment' },
      char = '┊',
    },
  }
end

return plugin
