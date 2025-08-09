-- [nfnl] fnl/_plugins/treesitter.fnl
local treesitter_config = require("nvim-treesitter.configs")
local plugin = {priority = 10}
plugin.config = function()
  return treesitter_config.setup({ensure_installed = "all", highlight = {additional_vim_regex_highlighting = {"markdown"}, enable = true}, ignore_install = {"ipkg"}, incremental_selection = {enable = true, keymaps = {init_selection = "<localleader><CR>", node_decremental = "<S-TAB>", node_incremental = "<TAB>", scope_incremental = "<C-TAB>"}}, indent = {enable = true}, textobjects = plugin.text_objects()})
end
plugin.text_objects = function()
  return {enable = true, lsp_interop = {border = "none", enable = true, peek_definition_code = {["<leader>dt"] = "@function.outer"}}, move = {enable = true, goto_next_start = {["]]"] = "@function.outer", ["]a"] = "@parameter.outer"}, goto_previous_start = {["[["] = "@function.outer", ["[a"] = "@parameter.outer"}, set_jumps = true}, select = {enable = true, keymaps = {aa = "@parameter.outer", af = "@function.outer", ia = "@parameter.inner", ["if"] = "@function.inner"}, lookahead = true}, swap = {enable = true, swap_next = {["<C-l>"] = "@parameter.inner"}, swap_previous = {["<C-h>"] = "@parameter.inner"}}}
end
return plugin
