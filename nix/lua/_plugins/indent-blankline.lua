local M = {}

function M.setup()
  vim.cmd [[highlight IndentBlanklineChar guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineSpaceChar guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineContextStart guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineContextChar guifg=#1f1c29 gui=nocombine]]
  vim.cmd [[highlight IndentBlanklineSpaceCharBlankline guifg=#ff0000 gui=nocombine]]

  require('indent_blankline').setup {
    space_char = ' ',
    show_first_indent_level = true,
    char_list = {"│", "┊"},
    -- TODO: after treesitter
    -- use_treesitter = true,
    -- show_current_context = true,
  }
end

return M
