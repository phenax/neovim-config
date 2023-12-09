local M = {
  'lukas-reineke/indent-blankline.nvim',
  main = 'ibl'
}

function M.config()
  vim.cmd [[highlight IndentBlanklineChar guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineContextStart guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineContextChar guifg=#1f1c29 gui=nocombine]]

  -- Indent blankline
  require('ibl').setup {
    indent = {
      highlight = { 'CursorColumn', 'Comment' },
      char = '┊',
    },
  }
end

return M
