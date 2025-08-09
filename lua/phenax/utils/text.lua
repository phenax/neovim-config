-- [nfnl] fnl/phenax/utils/text.fnl
local text = {}
text.get_selection_lines = function()
  local start_row, start_col, end_row, end_col = text.get_selection_range()
  return vim.api.nvim_buf_get_text(0, (start_row - 1), (start_col - 1), (end_row - 1), end_col, {})
end
text.get_selection_text = function()
  local line_start, col_start, line_end, col_end = text.get_selection_range()
  local lines = vim.api.nvim_buf_get_lines(0, (line_start - 1), line_end, false)
  if (#lines == 0) then
    return ""
  elseif (#lines == 1) then
    return string.sub(lines[1], col_start, col_end)
  else
    lines[1] = string.sub(lines[1], col_start)
    lines[#lines] = string.sub(lines[#lines], 1, col_end)
    return table.concat(lines, "\n")
  end
end
text.get_selection_range = function()
  text.enter_normal_mode()
  local _local_2_ = vim.fn.getpos("'<")
  local _ = _local_2_[1]
  local line_start = _local_2_[2]
  local col_start = _local_2_[3]
  local _local_3_ = vim.fn.getpos("'>")
  local _0 = _local_3_[1]
  local line_end = _local_3_[2]
  local col_end = _local_3_[3]
  local col_end_adjusted = math.min(col_end, (vim.fn.col({line_end, "$"}) - 1))
  return line_start, col_start, line_end, col_end_adjusted
end
text.enter_normal_mode = function()
  return vim.cmd.normal(vim.api.nvim_replace_termcodes("<esc>", true, false, true))
end
return text
