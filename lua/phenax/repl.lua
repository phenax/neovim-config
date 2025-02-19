local defaultConfig = {
  -- Send clear seq before sending contents
  clear_screen = true,
  -- If not in visual mode, uses command for seletion
  default_selection_cmd = 'vip',
  -- Command to run in term
  command = 'node',
  -- Use vertical split?
  vertical = true,
  -- Preprocess input before running
  preprocess = function(input) return input end,

  -- Dimensions
  width = function(cols) return cols * 0.4 end,
  height = function(lines) return lines * 0.4 end,
}

_G.Repl = vim.tbl_extend('force', defaultConfig, {
  -- Repl configurations
  replModes = {
    node = { config = { command = 'node' } },
    shell = {
      config = { command = vim.env['SHELL'] },
      preprocess = function(input)
        return input:gsub('\\\n', '\n'):gsub('\n', '\\\n')
      end,
    },
    spider_repl = {
      config = {
        command = 'nix-shell --pure -p nodejs_23 --run "npx spider-repl"',
        vertical = true,
        width = function(w) return w * 0.3 end,
      },
    },
  },
})

local M = {
  channel_id = nil,
  window = nil,
  buffer = nil,
  config = _G.Repl,
  visible = false,
}

_G.Repl.apply_repl_mode = function(name) M.apply_repl_mode(name) end

function M.init()
  vim.keymap.set('n', '<c-t><c-t>', function() M.start_term() end)
  vim.keymap.set({ 'v', 'n' }, '<c-t><cr>', function() M.send_selection() end)
  vim.keymap.set('n', '<c-t>q', function() M.close_term() end)
  vim.keymap.set('n', '<c-t><Tab>', function() M.select_repl_mode() end)

  vim.api.nvim_create_user_command('ReplCmd', function(opts)
    if opts.nargs == 0 then return end
    M.config.command = opts.args
    print('[repl] command: ' .. M.config.command)
  end, { force = true, nargs = '*' })

  vim.api.nvim_create_user_command('ReplClearToggle', function()
    M.config.clear_screen = not M.config.clear_screen
    print('[repl] clear screen: ' .. (M.config.clear_screen and 'enabled' or 'disabled'))
  end, { force = true })

  vim.api.nvim_create_user_command('ReplVertToggle', function()
    M.config.vertical = not M.config.vertical
    print('[repl] split: ' .. (M.config.vertical and 'vertical' or 'horizontal'))
    if M.is_window_valid() then
      M.toggle_window()
      M.toggle_window()
    end
  end, { force = true })
end

M.init()

function M.close_term(close)
  if M.channel_id then
    vim.fn.jobstop(M.channel_id)
  end
  M.visible = false
  M.channel_id = nil
  if close and M.is_window_valid() then
    vim.api.nvim_win_close(M.window, true)
    M.window = nil
  end
  if close and M.is_buffer_valid() then
    vim.api.nvim_buf_delete(M.buffer, { force = true })
    M.buffer = nil
  end
end

function M.start_term()
  M.toggle_window()

  if M.channel_id then return end

  M.channel_id = vim.api.nvim_buf_call(M.buffer, function()
    return vim.fn.termopen(M.config.command, {
      on_exit = function(_, status) M.close_term(status == 0) end,
    })
  end)
end

function M.toggle_window()
  if M.channel_id and M.visible and M.is_window_valid() then
    vim.api.nvim_win_close(M.window, true)
    M.window = nil
    M.visible = false
  else
    if not M.is_buffer_valid() then
      M.buffer = vim.api.nvim_create_buf(false, false)
    end

    M.window = vim.api.nvim_open_win(M.buffer, false, { vertical = M.config.vertical })
    if M.config.vertical then
      vim.api.nvim_win_set_width(M.window, math.floor(M.config.width(vim.o.columns)))
    else
      vim.api.nvim_win_set_height(M.window, math.floor(M.config.height(vim.o.lines)))
    end
    vim.api.nvim_set_option_value('winfixbuf', true, { win = M.window })
    vim.api.nvim_set_option_value('number', false, { win = M.window })
    vim.api.nvim_set_option_value('signcolumn', 'no', { win = M.window })
    vim.api.nvim_set_option_value('winbar', M.config.command, { win = M.window })

    M.visible = true
  end
end

function M.send_selection()
  local oldPos = nil
  local isVisualMode = vim.fn.mode():match('[vV]')
  if not isVisualMode then
    oldPos = vim.api.nvim_win_get_cursor(0)
    -- Select paragraph if not in visual mode
    vim.cmd.normal(M.config.default_selection_cmd)
  end

  -- The '< and '> marks only get updated after leaving visual mode
  vim.cmd.normal(vim.api.nvim_replace_termcodes('<esc>', true, false, true))

  local selected_text = M.get_selection_text()
  -- Reset cursor position
  if oldPos then
    vim.api.nvim_win_set_cursor(0, oldPos)
  end
  M.send(selected_text, true)
end

function M.send(contents, with_return)
  if M.channel_id == nil then
    print('Starting term...')
    M.start_term()
  end

  if M.channel_id == nil or M.channel_id <= 0 then return end

  local input = M.config.preprocess(contents)
  if not input then return end

  -- Send clear screen sequence
  if M.config.clear_screen then
    vim.api.nvim_chan_send(M.channel_id, '\x0c')
  end

  vim.api.nvim_chan_send(M.channel_id, input)

  -- Add newline to the end
  if with_return then
    vim.api.nvim_chan_send(M.channel_id, '\n')
  end
end

function M.get_selection_text()
  local _, lineStart, colStart = unpack(vim.fn.getpos("'<"))
  local _, lineEnd, colEnd = unpack(vim.fn.getpos("'>"))
  local lines = vim.api.nvim_buf_get_lines(0, lineStart - 1, lineEnd, false)

  if #lines == 0 then
    return ''
  elseif #lines == 1 then
    return string.sub(lines[1], colStart, colEnd)
  else
    lines[1] = string.sub(lines[1], colStart)
    lines[#lines] = string.sub(lines[#lines], 1, colEnd)
    return table.concat(lines, '\n')
  end
end

function M.is_window_valid()
  return M.window and vim.api.nvim_win_is_valid(M.window)
end

function M.is_buffer_valid()
  return M.buffer and vim.api.nvim_buf_is_loaded(M.buffer)
end

function M.select_repl_mode()
  local options = vim.tbl_keys(M.config.replModes)
  table.sort(options)
  vim.ui.select(options, { prompt = 'Repl mode:' }, function(modeName)
    if not modeName then return end
    M.apply_repl_mode(modeName)
    vim.defer_fn(function() M.start_term() end, 200)
  end)
end

function M.apply_repl_mode(modeName)
  if not modeName then return end
  local mode = M.config.replModes[modeName]
  if not mode then
    print('Invalid repl mode' .. modeName)
    return
  end

  local newConfig = vim.tbl_extend('force', {}, defaultConfig, mode.config or {})
  -- Apply config
  for k, v in pairs(newConfig) do M.config[k] = v end
  -- Custom setup function
  if type(mode.setup) == 'function' then mode.setup() end
  -- Close existing repl if any
  M.close_term(true)
end

return M
