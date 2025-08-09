-- [nfnl] fnl/phenax/refactorings/shared.fnl
local tsutils = require("phenax.utils.treesitter")
local text = require("phenax.utils.text")
local _local_1_ = require("nfnl.core")
local nil_3f = _local_1_["nil?"]
local _local_2_ = require("phenax.utils.utils")
local present_3f = _local_2_["present?"]
local shared = {}
shared.extract_selected_text = function(opts)
  _G.assert((nil ~= opts), "Missing argument opts on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/shared.fnl:8")
  opts.name_prompt = (opts.name_prompt or "Name")
  local node = tsutils.get_node_at_cursor(0)
  if nil_3f(node) then
    return 
  else
  end
  local start_row, start_col, end_row, end_col = text.get_selection_range()
  local lines = text.get_selection_lines()
  local stmnt = opts.get_parent_statement(node:parent())
  if nil_3f(stmnt) then
    return 
  else
  end
  local val_name = vim.fn.input((opts.name_prompt .. ": "))
  if present_3f(val_name) then
    vim.api.nvim_buf_set_text(0, (start_row - 1), (start_col - 1), (end_row - 1), end_col, {val_name})
    return opts.create_declaration({name = val_name, node = stmnt, selected_lines = lines})
  else
    return nil
  end
end
shared.insert_before_node = function(node, lines)
  local stmnt_start_row, _ = node:start()
  return vim.api.nvim_buf_set_lines(0, stmnt_start_row, stmnt_start_row, false, lines)
end
shared.insert_after_node = function(node, lines, offset_lines)
  local stmnt_end_row, _ = node:end_()
  return vim.api.nvim_buf_set_lines(0, (stmnt_end_row + offset_lines + 1), (stmnt_end_row + offset_lines + 1), false, lines)
end
return shared
