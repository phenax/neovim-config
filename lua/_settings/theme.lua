vim.o.background = "dark"
vim.g.base16colorspace = 256

if vim.fn.has("termguicolors") then
  vim.go.t_8f = "[[38;2;%lu;%lu;%lum"
  vim.go.t_8b = "[[48;2;%lu;%lu;%lum"
  vim.go.termguicolors = true
end

vim.api.nvim_set_hl(0, 'Normal', { bg='NONE' })   
vim.api.nvim_set_hl(0, 'ColorColumn', { bg='#15121f' })   
