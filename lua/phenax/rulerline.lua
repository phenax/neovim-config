local M = {
  max_width = 50,
  simple_ruler_fts = { 'fugitive', 'buffer_manager', 'aerial', 'orgagenda' },
}

function M.special_buffers()
  if vim.bo.buftype == 'terminal' then return ' <term> ' end
  if vim.bo.filetype == 'fugitive' then return ' <git> ' end
  if vim.tbl_contains(M.simple_ruler_fts, vim.bo.filetype) then return '' end
  return nil
end

_G._RulerFilePath = function()
  local special_name = M.special_buffers()
  if special_name ~= nil then return special_name end

  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == '' then return '' end
  return ' ' .. M.get_short_path(buf_path, vim.o.columns) .. ' '
end

_G._RulerDiagnostic = function()
  if M.is_simple_ruler() then return '' end
  local diag = M.diagnostics()
  if diag == '' then return '' end
  return diag
end

_G._RulerFileStatus = function()
  if M.is_simple_ruler() then return '' end
  return '%m%r'
end

function M.path_segment()
  return '%#RulerFilePath#%{v:lua._RulerFilePath()}%#Normal#'
end

function M.status_segment()
  return '%#RulerFileStatus#%{%v:lua._RulerFileStatus()%}%#Normal#'
end

function M.diagnostics_segment()
  return '%{%v:lua._RulerDiagnostic()%}%#Normal#'
end

function M.is_simple_ruler()
  local current_ft = vim.bo.filetype
  for _, ft in ipairs(M.simple_ruler_fts) do
    if current_ft == ft then return true end
  end
  return false
end

function M.set_ruler_format()
  local format = '%=' .. M.status_segment()
      -- .. ' ' .. M.diagnostics_segment()
      .. ' %<%l/%L, %v'
      .. ' ' .. M.path_segment()
  vim.opt.rulerformat = '%' .. M.max_width .. '(' .. format .. '%)'
  vim.opt.statusline = '%<' .. [[%{repeat('─', winwidth(0))}]] .. '%= ' .. format
end

function M.initialize()
  vim.opt.ruler = true
  vim.opt.laststatus = 1
  M.set_ruler_format()
end

function M.diagnostics()
  local icons = { Error = '', Warn = '', Info = '', Hint = '' }
  local diagnostics = ''
  for severity, icon in pairs(icons) do
    local count = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if count > 0 then
      diagnostics = diagnostics .. ' %#DiagnosticSign' .. severity .. '#' .. icon .. ' ' .. count
    end
  end
  return diagnostics
end

function M.get_short_path(path, win_width)
  local segments = vim.split(path, '/')
  if #segments == 0 then
    return path
  elseif #segments == 1 then
    return segments[1]
  else
    local dir = segments[#segments - 1]
    local fname = segments[#segments]
    if string.len(dir) > 25 or string.len(dir .. fname) > 50 then
      dir = string.sub(dir, 1, 5) .. '…'
    elseif string.len(dir) > 5 and win_width < 85 then
      dir = string.sub(dir, 1, 5) .. '…'
    end
    if string.len(fname) > 40 then fname = string.sub(fname, 1, 10) .. '…' .. string.sub(fname, -10, -1) end
    return dir .. '/' .. fname
  end
end

return M
