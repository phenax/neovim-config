local M = {
  'Exafunction/codeium.vim',
  enabled = false,
}

function M.config()
  vim.g.codeium_enabled = false
  vim.api.nvim_set_keymap('i', '<c-g><c-g>', 'codeium#Accept()', { silent = true, expr = true })
end

return M
