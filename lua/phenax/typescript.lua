-- [nfnl] fnl/phenax/typescript.fnl
local core = require("nfnl.core")
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local ts = {}
ts.initialize = function()
  local function _2_(val_1_auto)
    return ts.typecheck(core.first(val_1_auto.fargs))
  end
  return vim.api.nvim_create_user_command("Tsc", _2_, {nargs = "*"})
end
ts.typecheck = function(path)
  vim.fn.setqflist({}, "r")
  vim.cmd.copen()
  return ts.run_tsc_async(path)
end
ts.add_line_to_qflist = function(line)
  local err_qf_item = ts.parse_tsc_error_to_qfitem(line)
  if present_3f(err_qf_item) then
    local function _3_()
      return vim.fn.setqflist({err_qf_item}, "a")
    end
    return vim.schedule(_3_)
  else
    return nil
  end
end
ts.parse_tsc_error_to_qfitem = function(error_line)
  local path, line, col, msg = error_line:match("^(.-)%((%d+),(%d+)%)%s*:%s*(.+)$")
  if (path and line and col) then
    return {col = tonumber(col), filename = path, lnum = tonumber(line), text = msg, type = "E"}
  else
    return nil
  end
end
ts.get_tsc_command = function(_3fpath)
  local stat = vim.uv.fs_stat((_3fpath or "."))
  local path_args = {}
  if (stat and (stat.type == "directory")) then
    path_args = {"-p", (_3fpath or ".")}
  else
    path_args = {_3fpath}
  end
  return core.concat(ts.get_tsc(), path_args, {"--pretty", "false", "--noEmit"})
end
ts.run_tsc_async = function(_3fpath)
  local function on_exit(result)
    vim.notify(("Exited with: " .. result.code), vim.log.levels.INFO)
    if present_3f(result.stderr) then
      return vim.notify(("[tsc errors" .. ": " .. result.code .. "] " .. result.stderr), vim.log.levels.ERROR)
    else
      return nil
    end
  end
  local function on_stdout(data)
    if present_3f(data) then
      return vim.iter(data:gmatch("[^\r\n]+")):each(ts.add_line_to_qflist)
    else
      return nil
    end
  end
  local function _9_(_, data)
    return on_stdout(data)
  end
  local function _10_(res)
    local function _11_()
      return on_exit(res)
    end
    return vim.schedule(_11_)
  end
  return vim.system(ts.get_tsc_command(_3fpath), {text = true, stdout = _9_}, _10_)
end
ts.get_tsc = function()
  if vim.uv.fs_stat("./node_modules/.bin/tsc") then
    return {"./node_modules/.bin/tsc"}
  else
    return {"tsc"}
  end
end
return ts
