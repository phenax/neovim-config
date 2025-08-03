local M = {}

function M.initialize()
  vim.api.nvim_create_user_command('Tsc', function(opts)
    vim.fn.setqflist({}, 'r')
    vim.cmd.copen()

    local path = opts.fargs[1]
    M.run_tsc_async(path)
  end, { nargs = '*' })
end

function M.add_line_to_qflist(line)
  local err = M.parse_tsc_error_to_qfitem(line)
  if not err then return end
  vim.schedule(function()
    vim.fn.setqflist({ err }, 'a')
  end)
end

function M.parse_tsc_error_to_qfitem(error_line)
  local path, line, col, msg = error_line:match('^(.-)%((%d+),(%d+)%)%s*:%s*(.+)$')
  if not path or not line or not col then return nil end
  return { filename = path, lnum = tonumber(line), col = tonumber(col), text = msg, type = 'E' }
end

function M.get_tsc_command(path)
  ---@diagnostic disable-next-line: undefined-field
  local stat = vim.uv.fs_stat(path or '.')
  local path_args = {}
  if stat and stat.type == 'directory' then
    path_args = { '-p', path or '.' }
  else
    path_args = { path }
  end

  return require 'phenax.utils.list'.concat(M.get_tsc(), path_args, {
    '--pretty', 'false',
    '--noEmit',
  })
end

function M.run_tsc_async(path)
  vim.system(M.get_tsc_command(path), {
    text = true,
    stdout = function(_, data)
      if not data then return end
      vim.iter(data:gmatch('[^\r\n]+')):each(M.add_line_to_qflist)
    end,
  }, function(res)
    vim.schedule(function()
      vim.notify('Exited with: ' .. res.code, vim.log.levels.INFO)
      if res.stderr and res.stderr ~= '' then
        vim.notify('[tsc errors' .. ': ' .. res.code .. '] ' .. res.stderr, vim.log.levels.ERROR)
      end
    end)
  end)
end

function M.get_tsc()
  ---@diagnostic disable-next-line: undefined-field
  if vim.uv.fs_stat('./node_modules/.bin/tsc') then
    return { './node_modules/.bin/tsc' }
  end
  return { 'tsc' }
end

return M
