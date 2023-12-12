return {
  'Exafunction/codeium.vim',
  enabled = false,

  config = function()
    vim.g.codeium_enabled = false
    vim.api.nvim_set_keymap('i', '<c-g><c-g>', 'codeium#Accept()', { silent = true, expr = true })
  end,
}
