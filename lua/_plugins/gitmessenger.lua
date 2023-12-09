local M = {
  'rhysd/git-messenger.vim'
}

function M.config()
  vim.keymap.set('n', '<localleader>gm', ':GitMessenger<cr>')
end

return M

