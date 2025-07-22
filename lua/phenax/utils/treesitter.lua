local M = {}

--- @param node TSNode
--- @param pred fun(n: TSNode):boolean
--- @return TSNode?
function M.find_closest_parent(node, pred)
  if pred(node) then return node end

  local parent = node:parent()
  if parent == nil then return nil end

  return M.find_closest_parent(parent, pred)
end

--- @param node TSNode
--- @param types table
--- @return TSNode?
function M.find_closest_parent_of_type(node, types)
  return M.find_closest_parent(node, function(n)
    return vim.tbl_contains(types, n:type())
  end)
end

--- @param winnr number?: Window number (default = 0)
--- @return TSNode?
function M.get_node_at_cursor(winnr)
  return require 'nvim-treesitter.ts_utils'.get_node_at_cursor(winnr)
end

--- @param bufnr number?: Buffer number (default = 0)
function M.get_root_node(bufnr)
  local parser = vim.treesitter.get_parser(bufnr, vim.bo[bufnr].filetype)
  if not parser then return nil end
  return parser:parse()[1]:root()
end

function M.get_node_indentation(node)
  local end_row, _ = node:start()
  local line = vim.api.nvim_buf_get_lines(0, end_row, end_row + 1, false)[1]
  return string.match(line, '^%s*') or ''
end

return M
