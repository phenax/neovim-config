local list = {}

function list.concat(start, ...)
  local result = start
  for i = 1, select('#', ...) do
    result = vim.list_extend(result, select(i, ...) or {})
  end
  return result
end

return list
