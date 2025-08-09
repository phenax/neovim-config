-- [nfnl] fnl/_plugins/treesj.fnl
local treesj = require("treesj")
local function config()
  vim.keymap.set("n", "<leader>tt", "<cmd>TSJToggle<cr>")
  vim.keymap.set("n", "<leader>ts", "<cmd>TSJSplit<cr>")
  vim.keymap.set("n", "<leader>tj", "<cmd>TSJJoin<cr>")
  return treesj.setup({max_join_length = 200, use_default_keymaps = false})
end
return {config = config}
