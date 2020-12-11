local utils = {}

function utils.nmap(key, action)
  fn.nvim_set_keymap('n', key, action, {})
end

function utils.set(k, v)
  if v == true or v == false then
    key = k
    if not v then key = 'no'..k end
    vim.api.nvim_command('set ' .. key)
  else
    vim.api.nvim_command('set ' .. k .. '=' .. v)
  end
end

function utils.fexists(file)
  return os.rename(file, file) and true or false
end

return utils
