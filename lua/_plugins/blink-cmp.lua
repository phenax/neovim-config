-- [nfnl] fnl/_plugins/blink-cmp.fnl
local blink = require("blink.cmp")
local function get_valid_bufs()
  local function _1_(bufnr)
    return (vim.bo[bufnr].buftype == "")
  end
  return vim.tbl_filter(_1_, vim.api.nvim_list_bufs())
end
local keys = {["<C-b>"] = {"scroll_documentation_up", "fallback"}, ["<C-f>"] = {"scroll_documentation_down", "fallback"}, ["<C-y>"] = {"select_and_accept"}, ["<CR>"] = {"accept", "fallback"}, ["<S-Tab>"] = {"snippet_backward", "fallback"}, ["<Tab>"] = {"snippet_forward", "fallback"}, preset = "default"}
local function config()
  return blink.setup({completion = {documentation = {auto_show = true, auto_show_delay_ms = 80}, ghost_text = {enabled = false}}, fuzzy = {implementation = "prefer_rust_with_warning"}, keymap = keys, sources = {default = {"lsp", "path", "snippets", "buffer"}, per_filetype = {org = {"orgmode", "path", "snippets", "buffer"}}, providers = {buffer = {max_items = 5, opts = {get_bufnrs = get_valid_bufs}, score_offset = ( - 5)}, lsp = {fallbacks = {}, score_offset = 20}, orgmode = {module = "orgmode.org.autocompletion.blink", name = "Orgmode", score_offset = 20}, path = {score_offset = 15}, snippets = {max_items = 5, score_offset = 10}}}})
end
return {config = config}
