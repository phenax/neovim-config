-- [nfnl] fnl/phenax/pack_config.fnl
local core = require("nfnl.core")
local pack = {}
pack.load = function(path)
  local specs = vim.tbl_values(pack.load_modules(path))
  local function _1_(m1, m2)
    return pack.package_sorter(m1, m2)
  end
  table.sort(specs, _1_)
  for _, spec in ipairs(specs) do
    pack.configure_module_spec(spec)
  end
  return nil
end
pack.configure_module_spec = function(spec)
  if (not spec or (spec.enabled == false)) then
    return 
  else
  end
  local function _configure()
    for _, value in ipairs((spec.keys or {})) do
      local key = value[1]
      local action = value[2]
      vim.keymap.set((value.mode or "n"), key, action, {remap = value.remap, silent = value.silent})
    end
    if core["function?"](spec.config) then
      return spec.config()
    else
      return nil
    end
  end
  local ok, error = pcall(_configure)
  if not ok then
    return vim.notify(("[Plugin config error: " .. (spec.name or "<unknown>") .. "] " .. error), vim.log.levels.ERROR)
  else
    return nil
  end
end
pack.load_modules = function(path)
  local modules_names = pack.ls_modules(path)
  local mods = {}
  for _, modname in pairs(modules_names) do
    local defaults = {enabled = true, name = modname, priority = 0}
    local ok, mod = pcall(require, modname)
    if ok then
      mods[modname] = vim.tbl_extend("force", defaults, (mod or {enabled = false}))
    else
      vim.notify(("[Plugin load error: " .. modname .. "] " .. mod), vim.log.levels.ERROR)
    end
  end
  return mods
end
pack.ls_modules = function(path)
  local handle = vim.uv.fs_scandir((vim.fn.stdpath("config") .. "/lua/" .. path))
  local modules = {}
  while handle do
    local name, _ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    else
    end
    if string.match(name, ".lua$") then
      local modname = (path .. "." .. string.gsub(name, ".lua$", ""))
      table.insert(modules, modname)
    else
    end
  end
  return modules
end
pack.package_sorter = function(m1, m2)
  if (m1.priority ~= m2.priority) then
    return (m1.priority > m2.priority)
  else
    return (m1.name < m2.name)
  end
end
return pack
