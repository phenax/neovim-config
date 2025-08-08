-- [nfnl] fnl/phenax/utils/treesitter.fnl
local core = require("nfnl.core")
local ts_utils = require("nvim-treesitter.ts_utils")
local M = {}
M.find_closest_parent = function(node, pred)
  if pred(node) then
    return node
  else
    local parent = node:parent()
    if parent then
      return M.find_closest_parent(parent, pred)
    else
      return nil
    end
  end
end
M.find_closest_parent_of_type = function(node, types)
  local function _3_(n)
    return vim.tbl_contains(types, n:type())
  end
  return M.find_closest_parent(node, _3_)
end
M.get_node_at_cursor = ts_utils.get_node_at_cursor
M.get_root_node = function(bufnr)
  local ft = vim.bo[bufnr].filetype
  local parser = vim.treesitter.get_parser(bufnr, ft)
  if parser then
    return core.first(parser:parse()):root()
  else
    return nil
  end
end
M.get_node_indentation = function(node)
  local end_row, _ = node:start()
  local _let_5_ = vim.api.nvim_buf_get_lines(0, end_row, (end_row + 1), false)
  local line = _let_5_[1]
  return core.str(string.match(line, "^%s*"))
end
return M
