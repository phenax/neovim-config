-- [nfnl] fnl/phenax/curly-repl.fnl
local core = require("nfnl.core")
local curly = {}
curly.repl_config = function()
  local cfg_path = vim.fn.stdpath("config")
  if vim.g.__phenax_test then
    cfg_path = vim.fn.expand("~/nixos/config/nvim")
  else
  end
  return {command = ("PATH=\"$PATH:" .. cfg_path .. "/bin\" zsh"), env = curly.get_env, preprocess = curly.command_preprocessor, preprocess_buffer_lines = curly.multi_command_preprocessor, restart_job_on_send = true, clear_screen = false}
end
curly.command_preprocessor = function(cmd_str)
  local parsed_cmd = curly.curl_command_parser(cmd_str)
  return (" " .. curly.command_slashify(parsed_cmd))
end
curly.multi_command_preprocessor = function(cmd_lines)
  local cmds = {}
  for _, line in ipairs(cmd_lines) do
    local cmd = ""
    if core["empty?"](line) then
      table.insert(cmds, curly.command_preprocessor(cmd))
      cmd = ""
    else
      cmd = (cmd .. "\n" .. line)
    end
  end
  return table.concat(cmds, ";\n")
end
curly.curl_command_parser = function(cmd_str)
  local json_started = false
  local json_str = ""
  local cmd = {}
  local lines = string.gmatch(string.gsub(cmd_str, "\\\n", "\n"), "([^\n]*)\n?")
  for line in lines do
    local trimmed_line = string.gsub(string.gsub(string.gsub(line, "^%s*", ""), "%s*$", ""), "%s*#%s.*$", "")
    if json_started then
      json_str = (json_str .. trimmed_line)
      if (trimmed_line == "}") then
        local ok, _ = pcall(vim.json.decode, json_str)
        if ok then
          json_started = false
          table.insert(cmd, vim.json.encode(json_str))
        else
        end
      else
      end
    elseif (trimmed_line == "{") then
      json_started = true
      json_str = (json_str .. trimmed_line)
    else
      table.insert(cmd, trimmed_line)
    end
  end
  return table.concat(cmd, " ")
end
curly.command_slashify = function(input)
  return string.gsub(string.gsub(input, "\\\n", "\n"), "\n", " \\\n")
end
curly.get_env = function()
  local handle = io.open("./env.json", "r")
  if handle then
    local result = handle:read("a")
    handle:close()
    return vim.json.decode(result)
  else
    return nil
  end
end
return curly
