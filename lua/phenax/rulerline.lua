local M = {
  max_width = 50,
  simple_ruler_fts = { 'fugitive', 'terminal', 'buffer_manager', 'TelescopePrompt' },
}

local state = { last_window = nil }

function M.update_last_window()
  state.last_window = vim.api.nvim_get_current_win()
  vim.cmd.echo()
  M.set_ruler_format()
end

function M.get_window()
  local win = state.last_window or vim.api.nvim_get_current_win()
  local is_valid = win and vim.api.nvim_win_is_valid(win)
  if not is_valid then return 0 end
  return win
end

_G._RulerFilePath = function()
  local win = M.get_window()
  local buf_path = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win) or 0)
  if M.is_simple_ruler() then return '' end
  if buf_path == '' then return '' end
  return ' ' .. M.get_short_path(buf_path, vim.o.columns) .. ' '
end

-- _G._RulerDiagnostic = function()
--   if M.is_simple_ruler() then return '' end
--   local diag = M.diagnostics()
--   if diag == '' then return '' end
--   return diag
-- end

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

-- function M.diagnostics_segment()
--   return '%{%v:lua._RulerDiagnostic()%}%#Normal#'
-- end

function M.is_simple_ruler()
  local current_ft = vim.bo.filetype
  for _, ft in ipairs(M.simple_ruler_fts) do
    if current_ft == ft then return true end
  end
  return false
end

function M.set_ruler_format()
  -- local ft_segment = '%#RulerFileType#%y%#Normal# '
  -- M.diagnostics_segment() .. ' ' ..
  vim.opt.rulerformat = '%' .. M.max_width ..
      '(%=' .. M.status_segment() ..
      ' %<%l/%L, %v ' ..
      M.path_segment() .. '%)'
end

function M.init()
  vim.opt.ruler = true
  M.set_ruler_format()
  state.last_window = vim.api.nvim_get_current_win()
  vim.api.nvim_create_autocmd({ 'WinEnter' }, {
    pattern = '*',
    callback = function() M.update_last_window() end,
  })
end

-- function M.diagnostics()
--   local icons = { Error = '', Warn = '', Info = '', Hint = '' }
--   local diagnostics = ''
--   for severity, icon in pairs(icons) do
--     local count = #vim.diagnostic.get(nil, { severity = vim.diagnostic.severity[string.upper(severity)] })
--     if count > 0 then
--       diagnostics = diagnostics .. ' %#DiagnosticSign' .. severity .. '#' .. icon .. ' ' .. count
--     end
--   end
--   return diagnostics
-- end

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

M.init()

return M
