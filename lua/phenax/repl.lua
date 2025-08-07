local text = require 'phenax.utils.text'

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
  preprocess_buffer_lines = function(lines) return { table.concat(lines, '\n') } end,
  -- Restart the job for every send
  restart_job_on_send = false,

  -- Dimensions
  width = function(cols) return cols * 0.4 end,
  height = function(lines) return lines * 0.4 end,
}

local function command_slashify(input)
  return input:gsub('\\\n', '\n'):gsub('\n', ' \\\n')
end

_G.Repl = vim.tbl_extend('force', defaultConfig, {
  -- Repl configurations
  replModes = {
    node = { config = { command = 'node' } },
    shell = {
      config = {
        command = vim.env['SHELL'],
        preprocess = command_slashify,
      },
    },
    shell_curl = {
      config = require 'phenax.curly-repl'.repl_config(),
    },
    -- spider_repl = {
    --   config = {
    --     command = 'nix-shell -p nodejs_23 --run "LD_LIBRARY_PATH="" npx spider-repl -b brave"',
    --     vertical = true,
    --     width = function(w) return w * 0.3 end,
    --   },
    -- },
  },
})

-- TODO: Pre-configure test-runners repl modes
-- jest = {
--   config = {
--     command = vim.env['SHELL'],
--     vertical = true,
--     clear_screen = true,
--     preprocess = function(_)
--       local currentFilePath = vim.fn.fnamemodify(vim.fn.expand('%'), ':p')
--       local jestRoot = vim.fs.root(currentFilePath, 'jest.config.js')
--       if not jestRoot then return end
--       return 'sh -c "cd ' ..
--           jestRoot ..
--           ' && pnpm dlx jest --runTestsByPath ' ..
--           currentFilePath ..
--           '"'
--     end,
--   }
-- },
-- cypress = {
--   config = {
--     command = vim.env['SHELL'],
--     vertical = true,
--     clear_screen = false,
--     preprocess = function(_)
--       local currentFilePath = vim.fn.fnamemodify(vim.fn.expand('%'), ':p')
--       return 'pnpm dlx cypress run --headless --e2e --spec "' .. currentFilePath .. '"'
--     end,
--   }
-- }

local M = {
  channel_id = nil,
  window = nil,
  buffer = nil,
  config = _G.Repl,
  visible = false,
}

_G.Repl.apply_repl_mode = function(name) M.apply_repl_mode(name) end

function M.initialize()
  vim.keymap.set('n', '<c-t><c-t>', function() M.start_term() end)
  vim.keymap.set({ 'v', 'n' }, '<c-t><cr>', function() M.send_selection() end)
  vim.keymap.set({ 'v', 'n' }, '<c-t>]', function() M.send_buffer() end)
  vim.keymap.set('n', '<c-t>q', function() M.close_term() end)
  vim.keymap.set('n', '<c-t><Tab>', function() M.select_repl_mode() end)
  vim.keymap.set('n', '<c-t>c', function() M.send_interrupt() end)

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

function M.close_term(close)
  M.stop_job()
  M.visible = false
  if close and M.window ~= nil then
    pcall(vim.api.nvim_win_close, M.window, true)
    M.window = nil
  end
  if close and M.buffer ~= nil then
    pcall(vim.api.nvim_buf_delete, M.buffer, { force = true })
    M.buffer = nil
  end
end

function M.restart_job()
  M.stop_job()
  M.start_job()
end

function M.stop_job()
  if M.channel_id ~= nil then
    pcall(vim.fn.jobstop, M.channel_id)
  end
  M.channel_id = nil
end

function M.start_job()
  M.channel_id = vim.api.nvim_buf_call(M.buffer, function()
    local env = M.config.env
    if type(env) == "function" then env = env() end
    return vim.fn.jobstart(M.config.command, {
      term = true,
      env = env,
      -- on_exit = function(_, status) M.close_term(status == 0) end,
    })
  end)
end

function M.start_term(force_open)
  M.toggle_window(force_open)

  if not M.channel_id then
    M.start_job()
  end
end

function M.toggle_window(force_open)
  if force_open and M.visible and M.is_window_valid() then return end

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
    -- vim.api.nvim_set_option_value('winfixbuf', true, { win = M.window })
    -- vim.api.nvim_set_option_value('number', false, { win = M.window })
    -- vim.api.nvim_set_option_value('signcolumn', 'no', { win = M.window })
    vim.api.nvim_set_option_value('winbar', M.config.command, { win = M.window })

    M.visible = true
  end
end

function M.send_buffer()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local cmds = M.config.preprocess_buffer_lines(lines)
  if type(cmds) ~= 'table' then cmds = { cmds } end
  for _, cmd in ipairs(cmds) do
    M.send(cmd, true)
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

  local selected_text = M.config.preprocess(text.get_selection_text())
  -- Reset cursor position
  if oldPos then
    vim.api.nvim_win_set_cursor(0, oldPos)
  end
  M.send(selected_text, true)
end

function M.send_interrupt()
  if M.channel_id == nil then return end

  local ctrl_c = vim.api.nvim_replace_termcodes('<c-c>', true, false, true)
  vim.api.nvim_chan_send(M.channel_id, ctrl_c)
end

function M.send(input, with_return)
  if not input then return end

  if M.config.restart_job_on_send then
    M.close_term(true)
  end

  if M.channel_id == nil or M.channel_id <= 0 then
    M.start_term(M.config.restart_job_on_send)
  end

  if M.channel_id == nil or M.channel_id <= 0 then return end

  -- Send clear screen sequence
  if M.config.clear_screen then
    -- TODO: Scroll to bottom?
    vim.api.nvim_chan_send(M.channel_id, '\x0c')
  end

  vim.api.nvim_chan_send(M.channel_id, input)

  -- Add newline to the end
  if with_return then
    vim.api.nvim_chan_send(M.channel_id, '\n')
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
    vim.defer_fn(function() M.start_term(true) end, 200)
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

  -- Close existing repl if the command has changed
  if newConfig.command ~= M.config.command then
    M.close_term(true)
  end

  -- Apply config
  for k, v in pairs(newConfig) do M.config[k] = v end
  -- Custom setup function
  if type(mode.setup) == 'function' then mode.setup() end
end

return M
