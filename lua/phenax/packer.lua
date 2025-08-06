local packer = {}

--- @class Spec
--- @field enabled boolean?
--- @field keys table
--- @field config function

function packer.load(path)
  packer.ls_mod(path, packer.load_module_spec)
end

function packer.load_module_spec(module_name)
  local function load_inner()
    --- @type Spec
    local spec = require(module_name)
    if not spec or spec.enabled == false then return end

    -- TODO: Get rid of keymap stuff later and do that manually
    for _, value in ipairs(spec.keys or {}) do
      vim.keymap.set(value.mode or 'n', value[1], value[2], {
        remap = value.remap,
        silent = value.silent,
      })
    end

    if spec.config then spec.config() end
  end

  local ok, error = pcall(load_inner)
  if not ok then
    vim.notify('[Plugin load error: ' .. module_name .. '] ' .. error, vim.log.levels.ERROR)
  end
end

function packer.ls_mod(path, fn)
  local handle = vim.uv.fs_scandir(vim.fn.stdpath('config') .. '/lua/' .. path)
  while handle do
    local name, _ = vim.uv.fs_scandir_next(handle)
    if not name then
      break
    end

    if string.match(name, '.lua$') then
      fn(path .. '.' .. string.gsub(name, '.lua$', ''))
    end
  end
end

return packer
