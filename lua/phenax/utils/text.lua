local M = {}

function M.get_selection_lines()
  local start_row, start_col, end_row, end_col = M.get_selection_range()
  return vim.api.nvim_buf_get_text(0, start_row - 1, start_col - 1, end_row - 1, end_col, {})
end

function M.get_selection_text()
  local line_start, col_start, line_end, col_end = M.get_selection_range()
  local lines = vim.api.nvim_buf_get_lines(0, line_start - 1, line_end, false)

  if #lines == 0 then
    return ''
  elseif #lines == 1 then
    return string.sub(lines[1], col_start, col_end)
  else
    lines[1] = string.sub(lines[1], col_start)
    lines[#lines] = string.sub(lines[#lines], 1, col_end)
    return table.concat(lines, '\n')
  end
end

function M.get_selection_range()
  M.enter_normal_mode() -- The '< and '> marks only get updated after leaving visual mode
  local _, line_start, col_start = unpack(vim.fn.getpos("'<"))
  local _, line_end, col_end = unpack(vim.fn.getpos("'>"))

  col_end = math.min(col_end, vim.fn.col({ line_end, '$' }) - 1)
  return line_start, col_start, line_end, col_end
end

function M.enter_normal_mode()
  vim.cmd.normal(vim.api.nvim_replace_termcodes('<esc>', true, false, true))
end

return M
