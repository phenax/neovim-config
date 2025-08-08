-- [nfnl] fnl/phenax/search.fnl
local M = {}
M.initialize = function()
  vim.opt.grepprg = "rg --vimgrep --hidden "
  vim.keymap.set("n", "<c-\\>", ":noh<cr>")
  vim.keymap.set("n", "<localleader>rw", "*:%s//<c-r><c-w>")
  vim.keymap.set("x", "g/", "<Esc>/\\%V")
  vim.keymap.set("n", "z/", M.search_in_visible_lines, {noremap = true})
  return vim.keymap.set("n", "<c-c>f", "<cmd>copen<cr>:sil grep ")
end
M.search_in_visible_lines = function()
  local scrolloff = vim.o.scrolloff
  vim.o.scrolloff = 0
  M.norm("VHoL<Esc>")
  vim.o.scrolloff = scrolloff
  M.norm("``")
  return vim.fn.feedkeys("/\\%V")
end
M.norm = function(input)
  return vim.cmd.norm(vim.api.nvim_replace_termcodes(input, true, true, true))
end
return M
