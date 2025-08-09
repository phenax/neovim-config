-- [nfnl] fnl/phenax/rulerline.fnl
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local core = require("nfnl.core")
local str = require("nfnl.string")
local nil_3f = core["nil?"]
local contains_3f = core["contains?"]
local rulerline = {max_width = 50, simple_ruler_fts = {"fugitive", "orgagenda"}, ["show_diagnostics?"] = true, ["show_filestatus?"] = true, ["show_filename?"] = true, ["show_linenum?"] = true}
rulerline.initialize = function()
  vim.opt.ruler = true
  vim.opt.laststatus = 1
  return rulerline.set_ruler_format()
end
rulerline.special_buffers = function()
  if (vim.bo.buftype == "terminal") then
    return " <term> "
  elseif (vim.bo.filetype == "fugitive") then
    return " <git> "
  elseif vim.tbl_contains(rulerline.simple_ruler_fts, vim.bo.filetype) then
    return ""
  else
    return nil
  end
end
rulerline.path_segment = function()
  return "%#RulerFilePath#%{v:lua._RulerFilePath()}%#Normal#"
end
rulerline.status_segment = function()
  return "%#RulerFileStatus#%{%v:lua._RulerFileStatus()%}%#Normal#"
end
rulerline.diagnostics_segment = function()
  return "%{%v:lua._RulerDiagnostic()%}%#Normal#"
end
rulerline.is_simple_ruler = function()
  return contains_3f(rulerline.simple_ruler_fts, vim.bo.filetype)
end
rulerline.set_ruler_format = function()
  local diag
  if rulerline["show_diagnostics?"] then
    diag = (" " .. rulerline.diagnostics_segment())
  else
    diag = ""
  end
  local status
  if rulerline["show_filestatus?"] then
    status = (" " .. rulerline.status_segment())
  else
    status = ""
  end
  local filepath
  if rulerline["show_filename?"] then
    filepath = (" " .. rulerline.path_segment())
  else
    filepath = ""
  end
  local linenum
  if rulerline["show_linenum?"] then
    linenum = (" " .. "%<%l/%L, %v")
  else
    linenum = ""
  end
  local format = ("%=" .. diag .. status .. linenum .. filepath)
  vim.opt.rulerformat = ("%" .. rulerline.max_width .. "(" .. format .. "%)")
  vim.opt.statusline = ("%<" .. "%{repeat('\226\148\128', winwidth(0))}" .. "%= " .. format)
  return nil
end
rulerline.diagnostics = function()
  local icons = {Error = "\239\128\141", Hint = "\239\160\180", Info = "\239\129\154", Warn = "\239\129\177"}
  local function to_diagnostic_text(_7_)
    local severity = _7_[1]
    local icon = _7_[2]
    _G.assert((nil ~= icon), "Missing argument icon on /home/imsohexy/nixos/config/nvim/fnl/phenax/rulerline.fnl:55")
    _G.assert((nil ~= severity), "Missing argument severity on /home/imsohexy/nixos/config/nvim/fnl/phenax/rulerline.fnl:55")
    local severity_value = vim.diagnostic.severity[string.upper(severity)]
    local count = #vim.diagnostic.get(0, {severity = severity_value})
    if (count > 0) then
      return ("%#DiagnosticSign" .. severity .. "#" .. icon .. " " .. count)
    else
      return nil
    end
  end
  return str.join(" ", core.remove(nil_3f, core["map-indexed"](to_diagnostic_text, icons)))
end
rulerline.get_short_path = function(path, win_width)
  local segments = vim.split(path, "/")
  local _9_ = #segments
  if (_9_ == 0) then
    return path
  elseif (_9_ == 1) then
    return segments[1]
  else
    local _ = _9_
    local dir = segments[(#segments - 1)]
    local fname = segments[#segments]
    if ((string.len(dir) > 25) or (string.len((dir .. fname)) > 50)) then
      dir = (string.sub(dir, 1, 5) .. "\226\128\166")
    elseif ((string.len(dir) > 5) and (win_width < 85)) then
      dir = (string.sub(dir, 1, 5) .. "\226\128\166")
    else
    end
    if (string.len(fname) > 40) then
      fname = (string.sub(fname, 1, 10) .. "\226\128\166" .. string.sub(fname, ( - 10), ( - 1)))
    else
    end
    return (dir .. "/" .. fname)
  end
end
_G._RulerFilePath = function()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local special_name = rulerline.special_buffers()
  if not_nil_3f(special_name) then
    return special_name
  elseif (buf_path == "") then
    return ""
  else
    return (" " .. rulerline.get_short_path(buf_path, vim.o.columns) .. " ")
  end
end
_G._RulerDiagnostic = function()
  if rulerline.is_simple_ruler() then
    return ""
  else
    return (rulerline.diagnostics() or "")
  end
end
_G._RulerFileStatus = function()
  if rulerline.is_simple_ruler() then
    return ""
  else
    return "%m%r"
  end
end
return rulerline
