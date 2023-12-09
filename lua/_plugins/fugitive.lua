local M = {
  'tpope/vim-fugitive'
}

function M.config()
  vim.keymap.set('n', '<localleader>gs', ':G<cr>')
  vim.keymap.set('n', '<localleader>gaf', ':Git add %<cr>')
  vim.keymap.set('n', '<localleader>gcc', ':Git commit<cr>')
  vim.keymap.set('n', '<localleader>gca', ':Git commit --amend<cr>')
  vim.keymap.set('n', '<localleader>gpp', ':Git push<cr>')
  vim.keymap.set('n', '<localleader>gpu', ':Git pull<cr>')
end

return M
