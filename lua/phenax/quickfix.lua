local M = {}

function M.initialize()
  vim.keymap.set('n', '<c-c>o', '<cmd>copen<cr>')
  vim.keymap.set('n', '<leader>xx', function()
    vim.diagnostic.setqflist()
    vim.cmd.copen()
  end)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'qf' },
    callback = function()
      M.quickfix_window_keybinds()
    end,
  })
end

function M.quickfix_window_keybinds()
  vim.keymap.set('n', 'q', '<cmd>cclose<cr>', { nowait = true, buffer = true })
  vim.keymap.set('n', 'zf', '<cmd>Telescope quickfix<cr>', { buffer = true })
  vim.keymap.set('n', 'f', '<cmd>Telescope quickfix<cr>', { nowait = true, buffer = true })
  vim.keymap.set('n', ']h', '<cmd>cnewer<cr>', { buffer = true })
  vim.keymap.set('n', '[h', '<cmd>colder<cr>', { buffer = true })
end

return M
