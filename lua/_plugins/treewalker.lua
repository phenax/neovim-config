-- [nfnl] fnl/_plugins/treewalker.fnl
local treewalker = require("treewalker")
local function config()
  vim.keymap.set({"n", "v"}, "<Down>", "<cmd>Treewalker Down<cr>", {noremap = true})
  vim.keymap.set({"n", "v"}, "<Up>", "<cmd>Treewalker Up<cr>", {noremap = true})
  vim.keymap.set({"n", "v"}, "<Left>", "<cmd>Treewalker Left<cr>", {noremap = true})
  vim.keymap.set({"n", "v"}, "<Right>", "<cmd>Treewalker Right<cr>", {noremap = true})
  vim.keymap.set("n", "<C-Down>", "<cmd>Treewalker SwapDown<cr>", {noremap = true})
  vim.keymap.set("n", "<C-Up>", "<cmd>Treewalker SwapUp<cr>", {noremap = true})
  return treewalker.setup({highlight = true})
end
return {config = config}
