local M = {}

function M.location_hint(fn)
  local file = vim.fn.expand('%:t')
  local line = vim.fn.line('.')

  return file .. ':' .. line
end

function M.js_console_log()
  local hint = M.location_hint()
  return ("console.log('>> [%s]', {})"):format(hint)
end

function M.js_console_log_copied()
  local text = vim.fn.getreg("")
  local hint = M.location_hint()
  return ("console.log('>> [%s]', %s)"):format(hint, text)
end

return M
