local tsutils = require 'phenax.utils.treesitter'
local text = require 'phenax.utils.text'
local shared = {}

--- @class DeclrOpts
--- @field node TSNode
--- @field selected_lines string[]
--- @field name string
---
--- @class ExtractOpts
--- @field create_declaration fun(opts: DeclrOpts): nil
--- @field name_prompt? string
--- @field get_parent_statement fun(node: TSNode?): TSNode?
---
--- @param opts ExtractOpts
function shared.extract_selected_text(opts)
  opts.name_prompt = opts.name_prompt or 'Name'

  local node = tsutils.get_node_at_cursor(0)
  if not node then return end
  local start_row, start_col, end_row, end_col = text.get_selection_range()
  local lines = text.get_selection_lines()

  local stmnt = opts.get_parent_statement(node:parent())
  if not stmnt then return end

  local val_name = vim.fn.input(opts.name_prompt .. ': ')
  if val_name == "" then return end

  -- Replace expression with name
  vim.api.nvim_buf_set_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, { val_name })

  opts.create_declaration({
    node = stmnt,
    name = val_name,
    selected_lines = lines,
  })
end

--- @param node TSNode
--- @param lines string[]
function shared.insert_before_node(node, lines)
  local stmnt_start_row, _ = node:start()
  vim.api.nvim_buf_set_lines(0, stmnt_start_row, stmnt_start_row, false, lines)
end

--- @param node TSNode
--- @param lines string[]
--- @param offset_lines number
function shared.insert_after_node(node, lines, offset_lines)
  local stmnt_end_row, _ = node:end_()
  vim.api.nvim_buf_set_lines(0, stmnt_end_row + offset_lines + 1, stmnt_end_row + offset_lines + 1, false, lines)
end

return shared
