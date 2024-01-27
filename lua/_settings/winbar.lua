
-- Disable statusline
vim.opt.tabline = ''
vim.opt.statusline = 'this'
vim.opt.laststatus = 0

local W = {
  augroup = vim.api.nvim_create_augroup('WinBar', { clear = false });
  m = {
    mode = '%{mode()}',
    file = '%f',
    branch = '%{fugitive#Head()}',
    filetype = '%{&filetype}',
    line = '%c %l/%L',
    file_status = '%{&modified ? "●" : ""}',
    split = '%=',
  },
}

function W.get_active()
  return {
    {
      W.m.mode,
      ' ',
      W.m.branch,
      ' ',
      W.m.file,
    },
    {
      W.m.filetype,
      ' ',
      W.m.file_status,
      ' ',
      W.m.line,
    },
  }
end

function W.get_inactive()
  return {
    {
      W.m.file,
    },
    {
      W.m.filetype,
      ' ',
      W.m.file_status,
    },
  }
end

function W.get_bar(opts)
  if vim.api.nvim_get_current_win() == opts.win_id then
    return W.get_active()
  else
    return W.get_inactive()
  end
end

function W.get_bar_string(opts)
  local left, right = unpack(W.get_bar(opts))
  left = table.concat(left, '')
  right = table.concat(right, '')
  return left .. W.m.split .. right
end

vim.api.nvim_create_autocmd({ 'WinEnter', 'WinLeave' }, {
  callback = function(args)
    local win_id = vim.fn.bufwinid(args.buf)
    -- print(vim.inspect(args))
    vim.opt_local.winbar = W.get_bar_string({
      win_id = win_id
    })
  end,
})
