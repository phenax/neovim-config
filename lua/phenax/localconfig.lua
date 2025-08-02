local M = {
  safe_dirs_file = vim.fs.joinpath(
    vim.fn.stdpath('data'),
    'phenax-autoload-safe-dirs'
  ),
  local_config_file = '.local.lua',
}

function M.initialize()
  vim.keymap.set('n', '<leader>cz', function()
    M.prompt_add_safe(vim.fn.getcwd())
    M.load_local_config()
  end)

  vim.api.nvim_create_user_command('LocalConfigAllow', function()
    M.prompt_add_safe(vim.fn.getcwd())
    M.load_local_config()
  end, {})

  vim.api.nvim_create_autocmd('VimEnter', {
    callback = function()
      vim.defer_fn(function() M.load_local_config() end, 200)
    end,
  })
end

function M.load_local_config()
  if not M.file_exists(M.local_config_file) then return end
  if not M.is_safe_dir() then return end

  dofile(M.local_config_file)
  print 'Loaded .local.lua'
end

function M.is_safe_dir()
  local file = io.open(M.safe_dirs_file, 'r')
  if not file then return false end

  local cwd = vim.fn.getcwd()

  for dir in file:lines() do
    if dir == cwd then
      file:close()
      return true
    end
  end

  file:close()
  return false
end

function M.prompt_add_safe(dir)
  local file = io.open(M.safe_dirs_file, 'a+')
  if not file then return false end

  local answer = vim.fn.input('.local.lua found. Add directory as safe (y/n)? ')
  if answer:lower() ~= 'y' then return false end

  file:write(dir .. '\n')
  file:flush()
  file:close()
  return true
end

function M.file_exists(filepath)
  return vim.loop.fs_stat(filepath) ~= nil
end

return M
