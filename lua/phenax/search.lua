local M = {}

function M.initialize()
  vim.opt.grepprg = 'rg --vimgrep --hidden '

  -- Disable search highlighting
  vim.keymap.set('n', '<c-\\>', ':noh<cr>')
  -- Replace word
  vim.keymap.set('n', '<localleader>rw', '*:%s//<c-r><c-w>')
  -- Search in visual selection
  vim.keymap.set('x', 'g/', '<Esc>/\\%V')
  -- Search in visible lines
  vim.keymap.set('n', 'z/', M.search_in_visible_lines, { noremap = true })
  -- Grep + quickfix list
  vim.keymap.set('n', '<c-c>f', '<cmd>copen<cr>:sil grep ')
end

function M.search_in_visible_lines()
  local scrolloff = vim.o.scrolloff
  vim.o.scrolloff = 0
  M.norm "VHoL<Esc>"
  vim.o.scrolloff = scrolloff

  M.norm '``' -- Reset cursor
  vim.fn.feedkeys [[/\%V]]
end

function M.norm(input)
  vim.cmd.norm(
    vim.api.nvim_replace_termcodes(input, true, true, true))
end

return M
