-- Disable statusline
vim.opt.tabline = ''
vim.opt.statusline = '%#@_phenax.statusline#'
vim.opt.laststatus = 0

local W = {
  augroup = vim.api.nvim_create_augroup('@_bar', { clear = false }),
  m = {
    mode = '%{mode()}',
    file = '%f',
    filetype = '%{&filetype}',
    line = '%c %l/%L',
    file_status = '%{&modified ? "●" : ""}',
    split = '%=',
    hl_normal = '%#@_bar.mode.normal#',
    hl_inactive = '%#@_bar.mode.inactive#',
  },
}

function W.get_active()
  return {
    {
      W.m.hl_normal,
      W.m.mode,
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
      W.m.hl_inactive,
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
  if opts.win_id and vim.api.nvim_get_current_win() == opts.win_id then
    return W.get_active()
  else
    return W.get_inactive()
  end
end

function W.get_bar_string(opts)
  local left, right = unpack(W.get_bar(opts))
  return table.concat(left, '') .. W.m.split .. table.concat(right, '')
end

local ignore_fts = {
  'minifiles',
  'buffer_manager',
  'TelescopePrompt',
  'fugitive',
  'aerial',
  'Trouble',
}

local last_win_id = nil

vim.api.nvim_create_autocmd({ 'WinEnter', 'WinLeave', 'VimEnter' }, {
  callback = function(args)
    local win_id = last_win_id
    if vim.tbl_contains({ 'WinEnter', 'VimEnter' }, args.event) then
      win_id = vim.api.nvim_get_current_win()
      last_win_id = win_id
    end

    local ft = vim.api.nvim_buf_get_option(args.buf, 'filetype')
    local win_conf = win_id and vim.api.nvim_win_get_config(win_id) or { focusable = true }

    -- If ignored file type, or floating window, or not focusable, return
    if win_conf.relative ~= '' or not win_conf.focusable or vim.tbl_contains(ignore_fts, ft) then return end

    -- print(vim.inspect(args))
    -- print("[" .. ft .. "]")

    print('EVENT: ' .. args.event .. '.' .. vim.inspect(win_id))

    vim.wo[win_id].winbar = W.get_bar_string {
      win_id = win_id,
    }
  end,
})
