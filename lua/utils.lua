local utils = {}

function utils.nmap(key, action)
  fn.nvim_set_keymap('n', key, action, {})
end

function utils.set(k, v)
  if v == true or v == false then
    vim.api.nvim_command('set ' .. k)
  else
    vim.api.nvim_command('set ' .. k .. '=' .. v)
  end
end

return utils
