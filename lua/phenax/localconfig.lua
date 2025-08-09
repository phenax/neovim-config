-- [nfnl] fnl/phenax/localconfig.fnl
local _local_1_ = require("nfnl.core")
local nil_3f = _local_1_["nil?"]
local localconf = {local_config_file = ".local.lua", safe_dirs_file = vim.fs.joinpath(vim.fn.stdpath("data"), "phenax-autoload-safe-dirs")}
localconf.initialize = function()
  local function _2_()
    return localconf.trust_and_load_local_config()
  end
  vim.keymap.set("n", "<leader>cz", _2_)
  local function _3_()
    return localconf.trust_and_load_local_config()
  end
  vim.api.nvim_create_user_command("LocalConfigAllow", _3_, {})
  local function _4_()
    return vim.defer_fn(localconf.load_local_config, 200)
  end
  return vim.api.nvim_create_autocmd("VimEnter", {callback = _4_})
end
localconf.trust_and_load_local_config = function()
  if not localconf.is_safe_dir() then
    localconf.prompt_add_safe(vim.fn.getcwd())
  else
  end
  return localconf.load_local_config()
end
localconf.load_local_config = function()
  if (localconf.file_exists(localconf.local_config_file) and localconf.is_safe_dir()) then
    dofile(localconf.local_config_file)
    return print("Loaded .local.lua")
  else
    return nil
  end
end
localconf.is_safe_dir = function()
  local file = io.open(localconf.safe_dirs_file, "r")
  if nil_3f(file) then
    return false
  else
    local cwd = vim.fn.getcwd()
    local contains_cwd
    local function _7_(dir)
      return (dir == cwd)
    end
    contains_cwd = vim.iter(file:lines()):any(_7_)
    file:close()
    return contains_cwd
  end
end
localconf.prompt_add_safe = function(dir)
  local file = io.open(localconf.safe_dirs_file, "a+")
  assert(file, "Unable to safe dirs config")
  local answer = vim.fn.input(".local.lua found. Add directory as safe (y/n)? ")
  if (answer:lower() == "y") then
    file:write((dir .. "\n"))
    file:flush()
  else
  end
  return file:close()
end
localconf.file_exists = function(filepath)
  return (vim.uv.fs_stat(filepath) ~= nil)
end
return localconf
