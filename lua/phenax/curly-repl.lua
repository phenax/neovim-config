local M = {}

function M.repl_config()
  local cfg_path = vim.fn.stdpath('config')
  if vim.g.__phenax_test then
    cfg_path = vim.fn.expand '~/nixos/config/nvim'
  end

  return {
    command = 'PATH="$PATH:' .. cfg_path .. '/bin" zsh',
    clear_screen = false,
    restart_job_on_send = true,
    env = M.get_env,
    preprocess = M.command_preprocessor,
    preprocess_buffer_lines = M.multi_command_preprocessor,
  }
end

function M.command_preprocessor(cmd_str)
  local parsed_cmd = M.curl_command_parser(cmd_str)
  return ' ' .. M.command_slashify(parsed_cmd)
end

function M.multi_command_preprocessor(cmd_lines)
  local cmds = {}
  local cmd = ''
  for _, line in ipairs(cmd_lines) do
    if line == '' or line == nil then
      table.insert(cmds, M.command_preprocessor(cmd))
      cmd = ''
    else
      cmd = cmd .. '\n' .. line
    end
  end

  -- return cmds
  return table.concat(cmds, ';\n')
end

function M.curl_command_parser(cmd_str)
  local json_started = false
  local json_str = ''
  local cmd = {}

  for line in cmd_str:gsub('\\\n', '\n'):gmatch("([^\n]*)\n?") do
    -- TODO: Fix issue with `#` inside strings being stripped
    local trimmed_line = line:gsub('^%s*', ''):gsub('%s*$', ''):gsub('%s*#%s.*$', '')
    if json_started then
      json_str = json_str .. trimmed_line
      if trimmed_line == '}' then
        local ok, _ = pcall(vim.json.decode, json_str)
        if ok then
          json_started = false
          table.insert(cmd, vim.json.encode(json_str))
        end
      end
    elseif trimmed_line == '{' then
      json_started = true
      json_str = json_str .. trimmed_line
    else
      table.insert(cmd, trimmed_line)
    end
  end

  return table.concat(cmd, ' ')
end

function M.command_slashify(input)
  return input:gsub('\\\n', '\n'):gsub('\n', ' \\\n')
end

function M.get_env()
  local handle = io.open('./env.json', 'r')
  if not handle then return end

  local result = handle:read('a')
  handle:close()
  return vim.json.decode(result)
end

return M
