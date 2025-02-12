local plugin = {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  keys = {
    { '<leader>ti', '<cmd>lua require"incline".toggle()<cr>', mode = 'n' },
  },
}

local M = {
  component = {},
  show_filetype_icon = false,
}
M.segments = function()
  return {
    M.component.diagnostics,
    -- M.component.filetype,
    M.component.filename,
  }
end

function plugin.config()
  require('incline').setup {
    ignore = {
      filetypes = { 'fugitive', 'aerial', 'fugitiveblame', 'Trouble' },
      unlisted_buffers = true,
    },
    window = {
      padding = 0,
      margin = { horizontal = 0, vertical = 0 },
    },
    render = function(props) return M.render(props) end,
  }
  vim.o.statusline = [[%{repeat('─', winwidth(0))}]]
  vim.o.showmode = true
end

-- function M.component.filetype(props)
--   if not props.focused then return { '' } end
--   local name = vim.api.nvim_buf_get_name(props.buf)
--   local ft = vim.bo[props.buf].filetype
--   if not ft or ft == '' then return { '' } end
--   local icon_c = { '' }
--   if M.show_filetype_icon then
--     local icon, color = require('nvim-web-devicons').get_icon_color(name, ft)
--     icon_c = { ' ' .. icon, guifg = color }
--   end
--   return { icon_c, { ' ' .. ft .. ' ', group = 'InclineModeInactive' } }
-- end

function M.component.diagnostics(props)
  local icons = { Error = '', Warn = '', Info = '', Hint = '' }
  local diagnostics = {}
  for severity, icon in pairs(icons) do
    local n = #vim.diagnostic.get(props.buf, { severity = vim.diagnostic.severity[string.upper(severity)] })
    if n > 0 then
      table.insert(diagnostics, { ' ' .. icon .. ' ' .. n .. ' ', group = 'DiagnosticSign' .. severity })
    end
  end
  if #diagnostics == 0 then return { '' } end
  return diagnostics
end

function M.component.filename(props)
  local width = vim.fn.winwidth(props.win)
  local filename = M.getShortPath(vim.api.nvim_buf_get_name(props.buf), width)
  local bo = vim.bo[props.buf]

  local modified = bo.modified and '● ' or ''
  local readonly = bo.readonly and '[RO] ' or ''

  if string.len(filename) == 0 then
    return { ' λ ' .. modified, group = 'InclineModeNormal' }
  end

  local file_seg = ' ' .. filename .. ' ' .. modified .. readonly
  local buf_count = ' ' .. M.getBufferCountInfo() .. ' ';

  if props.focused then
    return { { file_seg, group = 'InclineModeNormal' }, { buf_count, group = 'InclineModeInverted' } }
  end

  return { { file_seg, group = 'InclineModeInactive' }, { buf_count, group = 'InclineModeInverted' } }
end

function M.render(props)
  return M.to_render_segments(props, M.segments())
end

function M.to_render_segments(props, segments)
  local result = {}
  for _, seg in ipairs(segments) do
    local ok, arr = pcall(seg, props)
    if ok and type(arr) == 'table' then table.insert(result, arr) end
  end
  return result
end

function M.getShortPath(path, win_width)
  local segments = vim.split(path, '/')
  if #segments == 0 then
    return path
  elseif #segments == 1 then
    return segments[1]
  else
    local dir = segments[#segments - 1]
    local fname = segments[#segments]
    if string.len(dir) > 25 or string.len(dir .. fname) > 50 or win_width < 85 then
      dir = string.sub(dir, 1, 5) .. '…'
    end
    if string.len(fname) > 40 then fname = string.sub(fname, 1, 10) .. '…' .. string.sub(fname, -10, -1) end
    return dir .. '/' .. fname
  end
end

function M.getBufferCountInfo()
  local total = vim.fn.len(vim.fn.getbufinfo({ buflisted = 1 }))
  return total
end

return plugin
