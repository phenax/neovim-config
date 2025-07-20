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

return M
