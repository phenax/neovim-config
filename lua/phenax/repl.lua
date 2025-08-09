-- [nfnl] fnl/phenax/repl.fnl
local text = require("phenax.utils.text")
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local present_3f = _local_1_["present?"]
local _local_2_ = require("nfnl.core")
local nil_3f = _local_2_["nil?"]
local curly = require("phenax.curly-repl")
local default_config
local function _3_(lines)
  return (lines * 0.4)
end
local function _4_(input)
  return input
end
local function _5_(lines)
  return {table.concat(lines, "\n")}
end
local function _6_(cols)
  return (cols * 0.4)
end
default_config = {clear_screen = true, command = "node", default_selection_cmd = "vip", height = _3_, preprocess = _4_, preprocess_buffer_lines = _5_, vertical = true, width = _6_, restart_job_on_send = false}
local function command_slashify(input)
  return string.gsub(string.gsub(input, "\\\n", "\n"), "\n", " \\\n")
end
_G.Repl = vim.tbl_extend("force", default_config, {replModes = {node = {config = {command = "node"}}, shell = {config = {command = vim.env.SHELL, preprocess = command_slashify}}, shell_curl = {config = curly.repl_config()}}})
local repl = {buffer = nil, channel_id = nil, config = _G.Repl, window = nil, visible = false}
_G.Repl.apply_repl_mode = function(name)
  return repl.apply_repl_mode(name)
end
repl.initialize = function()
  local function _7_()
    return repl.start_term()
  end
  vim.keymap.set("n", "<c-t><c-t>", _7_)
  local function _8_()
    return repl.send_selection()
  end
  vim.keymap.set({"v", "n"}, "<c-t><cr>", _8_)
  local function _9_()
    return repl.send_buffer()
  end
  vim.keymap.set({"v", "n"}, "<c-t>]", _9_)
  local function _10_()
    return repl.close_term()
  end
  vim.keymap.set("n", "<c-t>q", _10_)
  local function _11_()
    return repl.select_repl_mode()
  end
  vim.keymap.set("n", "<c-t><Tab>", _11_)
  local function _12_()
    return repl.send_interrupt()
  end
  vim.keymap.set("n", "<c-t>c", _12_)
  local function _13_(opts)
    if (opts.nargs ~= 0) then
      repl.config.command = opts.args
      return print(("[repl] command: " .. repl.config.command))
    else
      return nil
    end
  end
  vim.api.nvim_create_user_command("ReplCmd", _13_, {force = true, nargs = "*"})
  local function _15_()
    repl.config.clear_screen = not repl.config.clear_screen
    return print(("[repl] clear screen: " .. ((repl.config.clear_screen and "enabled") or "disabled")))
  end
  vim.api.nvim_create_user_command("ReplClearToggle", _15_, {force = true})
  local function _16_()
    repl.config.vertical = not repl.config.vertical
    print(("[repl] split: " .. ((repl.config.vertical and "vertical") or "horizontal")))
    if repl.is_window_valid() then
      repl.toggle_window()
      return repl.toggle_window()
    else
      return nil
    end
  end
  return vim.api.nvim_create_user_command("ReplVertToggle", _16_, {force = true})
end
repl.close_term = function(close)
  repl.stop_job()
  repl.visible = false
  if (close and not_nil_3f(repl.window)) then
    pcall(vim.api.nvim_win_close, repl.window, true)
    repl.window = nil
  else
  end
  if (close and not_nil_3f(repl.buffer)) then
    pcall(vim.api.nvim_buf_delete, repl.buffer, {force = true})
    repl.buffer = nil
    return nil
  else
    return nil
  end
end
repl.restart_job = function()
  repl.stop_job()
  return repl.start_job()
end
repl.stop_job = function()
  if not_nil_3f(repl.channel_id) then
    pcall(vim.fn.jobstop, repl.channel_id)
  else
  end
  repl.channel_id = nil
  return nil
end
repl.start_job = function()
  local function _21_()
    local env = repl.config.env
    if (type(env) == "function") then
      env = env()
    else
    end
    return vim.fn.jobstart(repl.config.command, {env = env, term = true})
  end
  repl.channel_id = vim.api.nvim_buf_call(repl.buffer, _21_)
  return nil
end
repl.start_term = function(force_open)
  repl.toggle_window(force_open)
  if not repl.channel_id then
    return repl.start_job()
  else
    return nil
  end
end
repl.toggle_window = function(force_open)
  if ((force_open and repl.visible) and repl.is_window_valid()) then
    return 
  else
  end
  if ((repl.channel_id and repl.visible) and repl.is_window_valid()) then
    vim.api.nvim_win_close(repl.window, true)
    repl.window = nil
    repl.visible = false
    return nil
  else
    if not repl.is_buffer_valid() then
      repl.buffer = vim.api.nvim_create_buf(false, false)
    else
    end
    repl.window = vim.api.nvim_open_win(repl.buffer, false, {vertical = repl.config.vertical})
    if repl.config.vertical then
      vim.api.nvim_win_set_width(repl.window, math.floor(repl.config.width(vim.o.columns)))
    else
      vim.api.nvim_win_set_height(repl.window, math.floor(repl.config.height(vim.o.lines)))
    end
    vim.api.nvim_set_option_value("winbar", repl.config.command, {win = repl.window})
    repl.visible = true
    return nil
  end
end
repl.send_buffer = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, ( - 1), false)
  local cmds = repl.config.preprocess_buffer_lines(lines)
  if (type(cmds) ~= "table") then
    cmds = {cmds}
  else
  end
  for _, cmd in ipairs(cmds) do
    repl.send(cmd, true)
  end
  return nil
end
repl.send_selection = function()
  local old_pos = nil
  local is_visual_mode = vim.fn.mode():match("[vV]")
  if not is_visual_mode then
    old_pos = vim.api.nvim_win_get_cursor(0)
    vim.cmd.normal(repl.config.default_selection_cmd)
  else
  end
  vim.cmd.normal(vim.api.nvim_replace_termcodes("<esc>", true, false, true))
  local selected_text = repl.config.preprocess(text.get_selection_text())
  if old_pos then
    vim.api.nvim_win_set_cursor(0, old_pos)
  else
  end
  return repl.send(selected_text, true)
end
repl.send_interrupt = function()
  if (repl.channel_id == nil) then
    return 
  else
  end
  local ctrl_c = vim.api.nvim_replace_termcodes("<c-c>", true, false, true)
  return vim.api.nvim_chan_send(repl.channel_id, ctrl_c)
end
repl.send = function(input, with_return)
  if not input then
    return 
  else
  end
  if repl.config.restart_job_on_send then
    repl.close_term(true)
  else
  end
  if (nil_3f(repl.channel_id) or (repl.channel_id <= 0)) then
    repl.start_term(repl.config.restart_job_on_send)
  else
  end
  if (nil_3f(repl.channel_id) or (repl.channel_id <= 0)) then
    return 
  else
  end
  if repl.config.clear_screen then
    vim.api.nvim_chan_send(repl.channel_id, "\f")
  else
  end
  vim.api.nvim_chan_send(repl.channel_id, input)
  if with_return then
    return vim.api.nvim_chan_send(repl.channel_id, "\n")
  else
    return nil
  end
end
repl.is_window_valid = function()
  return (repl.window and vim.api.nvim_win_is_valid(repl.window))
end
repl.is_buffer_valid = function()
  return (repl.buffer and vim.api.nvim_buf_is_loaded(repl.buffer))
end
repl.select_repl_mode = function()
  local options = vim.tbl_keys(repl.config.replModes)
  table.sort(options)
  local function _38_(mode_name)
    if present_3f(mode_name) then
      repl.apply_repl_mode(mode_name)
      local function _39_()
        return repl.start_term(true)
      end
      return vim.defer_fn(_39_, 200)
    else
      return nil
    end
  end
  return vim.ui.select(options, {prompt = "Repl mode:"}, _38_)
end
repl.apply_repl_mode = function(mode_name)
  if not mode_name then
    return 
  else
  end
  local mode = repl.config.replModes[mode_name]
  if not mode then
    print(("Invalid repl mode" .. mode_name))
    return 
  else
  end
  local new_config = vim.tbl_extend("force", {}, default_config, (mode.config or {}))
  if (new_config.command ~= repl.config.command) then
    repl.close_term(true)
  else
  end
  for k, v in pairs(new_config) do
    repl.config[k] = v
  end
  if (type(mode.setup) == "function") then
    return mode.setup()
  else
    return nil
  end
end
return repl
