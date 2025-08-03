local M = {
  window_size = function() return math.max(4, vim.o.lines * 0.3) end
}

function M.initialize()
  vim.keymap.set('n', '<c-c>o', '<cmd>copen<cr>')
  vim.keymap.set('n', '<leader>xx', function()
    vim.diagnostic.setqflist()
    vim.cmd.copen()
  end)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'qf' },
    callback = function()
      M.quickfix_window_setup()
    end,
  })
end

function M.quickfix_window_setup()
  vim.keymap.set('n', 'q', '<cmd>cclose<cr>', { nowait = true, buffer = true })
  vim.keymap.set('n', 'L', '<cmd>cnewer<cr>', { buffer = true })
  vim.keymap.set('n', 'H', '<cmd>colder<cr>', { buffer = true })
  vim.keymap.set('n', 'C', '<cmd>cexpr []<cr>', { buffer = true })

  -- Resize window
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if vim.api.nvim_get_option_value('filetype', { buf = buf }) == 'qf' then
    local h = math.floor(M.window_size())
    vim.api.nvim_win_set_height(win, h)
  end
end

return M
