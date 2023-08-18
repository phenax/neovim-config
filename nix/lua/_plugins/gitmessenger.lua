local M = {}

function M.setup()
  vim.keymap.set('n', '<localleader>gm', ':GitMessenger<cr>')
end

return M

