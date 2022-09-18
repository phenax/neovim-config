local utils = {}

function utils.nmap_options(key, action, options)
  vim.api.nvim_set_keymap('n', key, action, options)
end
function utils.nmap(key, action)
  utils.nmap_options(key, action, {})
end
function utils.nmap_silent(key, action)
  utils.nmap_options(key, action, { silent = true })
end
function utils.nnoremap(key, action)
  utils.nmap_options(key, action, { noremap = true })
end
function utils.xmap(key, action)
  vim.api.nvim_set_keymap('x', key, action, {})
end
function utils.imap(key, action)
  vim.api.nvim_set_keymap('i', key, action, { silent = true })
end

function utils.set_opt(k, v, opt)
  if v == true or v == false then
    key = k
    if not v then key = 'no'..k end
    vim.api.nvim_command('set ' .. key)
  else
    vim.api.nvim_command('set ' .. k .. opt .. v)
  end
end

function utils.set(k, v)
  utils.set_opt(k, v, '=')
end

function utils.append(k, v)
  utils.set_opt(k, v, '+=')
end

function utils.print_keys(tbl)
  local res = ""
  for key,_ in pairs(tbl) do
    res = res .. "," .. key
  end
  print(res)
end

function utils.mapList(func, array)
  local new_array = {}
  for i,v in ipairs(array) do
    new_array[i] = func(v)
  end
  return new_array
end

function utils.updateScheme(schemes)
  local toHl = function(str) return "hi "..str; end;
  local highlights = table.concat(utils.mapList(toHl, schemes), " | ")
  exec('autocmd ColorScheme * '..highlights)
end

function utils.fexists(file)
  return os.rename(file, file) and true or false
end

function utils.isOneOf(list, x)
  for _, v in pairs(list) do
    if v == x then return true end
  end
  return false
end

function utils.merge(a, b)
  for k, v in pairs(b) do
    a[k] = v
  end

  return a
end

return utils
