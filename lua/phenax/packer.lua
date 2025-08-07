local packer = {}

--- @class Spec
--- @field name string?
--- @field enabled boolean?
--- @field keys table?
--- @field config function?
--- @field priority number?

-- TODO: check if pack .active
function packer.load(path)
  ---@type table<Spec>
  local specs = vim.tbl_values(packer.load_modules(path))
  table.sort(specs, function(m1, m2)
    if m1.priority ~= m2.priority then return m1.priority > m2.priority end
    return m1.name < m2.name
  end)

  for _, spec in ipairs(specs) do
    packer.configure_module_spec(spec)
  end
end

function packer.configure_module_spec(spec)
  if not spec or spec.enabled == false then return end

  local function _configure()
    --- @todo Get rid of keymap stuff later and do that manually
    for _, value in ipairs(spec.keys or {}) do
      vim.keymap.set(value.mode or 'n', value[1], value[2], {
        remap = value.remap,
        silent = value.silent,
      })
    end

    if spec.config then spec.config() end
  end

  local ok, error = pcall(_configure)
  if not ok then
    vim.notify('[Plugin config error: ' .. (spec.name or '<unknown>') .. '] ' .. error, vim.log.levels.ERROR)
  end
end

--- @param path string
--- @return table<string, Spec>
function packer.load_modules(path)
  local handle = vim.uv.fs_scandir(vim.fn.stdpath('config') .. '/lua/' .. path)

  local mods = {}
  while handle do
    local name, _ = vim.uv.fs_scandir_next(handle)
    if not name then break end

    if string.match(name, '.lua$') then
      local mod_name = path .. '.' .. string.gsub(name, '.lua$', '')
      local ok, mod = pcall(require, mod_name)
      if ok then
        local defs = { name = mod_name, priority = 0, enabled = true }
        mods[mod_name] = vim.tbl_extend('force', defs, mod or { enabled = false })
      else
        vim.notify('[Plugin load error: ' .. mod_name .. '] ' .. mod, vim.log.levels.ERROR)
      end
    end
  end

  return mods
end

return packer
