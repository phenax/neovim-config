local M = {
  state = {},
}

M.keys = {
  { '<localleader>nn', function() M.toggleOpen() end },
  { '<localleader>nc', function() M.toggleOpen({ cwd = true }) end },
}

M.localKeys = {
  { '<tab>',         'mf' },     -- Mark
  { '<leader><tab>', 'mu' },     -- Unmark all
  { 'L',             '<cr>' },   -- Open/go in
  { 'H',             '-^' },     -- Go back
  { 'P',             '<c-w>z' }, -- Close preview
  { 'r',             'R' },      -- Rename
  { 'a',             '%' },      -- New file
  { 'A',             'd' },      -- New directory
  { '|',             'mfmx' },   -- Run with shell command
  { 'v',             'mfmv' },   -- Run with vim command

  -- Target
  { 'gt',            function() M.goToTarget() end },
  { 'mt',            function() M.markTarget() end },
  { 'mT',            function() M.unmarkTarget() end },

  -- Clipboard
  { '<C-y>',         function() M.copyAbsolutePath() end },
  { 'Y',             function() M.copyRelativePath() end },

  { 'g?',            '<cmd>help netrw-quickmap<cr>' }, -- Help
  { 'J',             'j' },
  { 'K',             'k' },
  { 'o',             '<nop>' },
  { '<c-v>',         'v' },
}

function M.config()
  vim.g.netrw_banner = false
  vim.g.netrw_liststyle = 1
  vim.g.netrw_keepdir = 1
  vim.g.netrw_sizestyle = 'H'
  vim.g.netrw_usetab = 1
  vim.g.netrw_localcopydircmd = 'cp -r'
  vim.g.netrw_hide = 1
  vim.g.netrw_list_hide = '^\\.\\.\\?/' -- .. vim.fn["netrw_gitignore#Hide"]()
  vim.g.netrw_sort_sequence = '.*[\\/],*'
  vim.g.netrw_sort_options = 'i'
  vim.g.netrw_preview = 1
  vim.g.netrw_alto = 0
  -- vim.g.Netrw_UserMaps = {
  --   { '<leader>gy', 'Somevimfnref' }
  -- }
end

function M.localConfig()
  vim.opt_local.signcolumn = 'yes'
  vim.opt_local.buflisted = false
  vim.opt_local.winbar = M.getWinbarExpr()
end

function M.getCurrentPath()
  return vim.b.netrw_curdir
end

function M.getCursorPath()
  return vim.fs.joinpath(M.getCurrentPath(), vim.fn['netrw#GX']())
end

function M.markTarget()
  M.state.target = M.getCurrentPath()
  vim.fn['netrw#MakeTgt'](M.state.target)
end

function M.unmarkTarget()
  M.state.target = nil
  vim.fn['netrw#MakeTgt'](nil)
end

function M.goToTarget()
  vim.cmd.Explore(M.state.target or vim.fn.getcwd())
end

function M.copyAbsolutePath()
  local path = vim.fn.fnamemodify(M.getCursorPath(), ':p')
  vim.cmd(':let @+="' .. path .. '"')
  vim.notify('Copied to clipboard: ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
end

function M.copyRelativePath()
  local path = vim.fn.fnamemodify(M.getCursorPath(), ':~:.')
  vim.cmd(':let @+="' .. path .. '"')
  vim.notify('Copied to clipboard: ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
end

function M.toggleOpen(opt)
  local arg = nil
  if opt and not opt.cwd then
    arg = vim.fn.expand('%:p:h')
  end

  if vim.bo.filetype == 'netrw' then
    vim.cmd.bdelete()
  else
    vim.cmd.Explore(arg)
  end
end

function M.getWinbarExpr()
  -- "[%{expand('%:.')}]"
  return "%#Normal#%{fnamemodify(b:netrw_curdir, ':~:.')} %= %{luaeval('_NetrwWinbarSegment()')}"
end

function _G._NetrwWinbarSegment()
  if not M.state.target then return '' end
  return '[target: ' .. vim.fn.fnamemodify(M.state.target, ':~:.') .. ']'
end

function M.init()
  local group = vim.api.nvim_create_augroup('netrw', { clear = true })
  -- NOTE: Using bufmodifiedset because filetype doesnt work
  vim.api.nvim_create_autocmd('BufModifiedSet', {
    pattern = '*',
    group = group,
    callback = function()
      if not (vim.bo and vim.bo.filetype == "netrw") then return end

      M.localConfig()
      M.applyKeys(M.localKeys, { buffer = true, remap = true })
    end
  })

  M.config()
  M.applyKeys(M.keys, { silent = true })
end

function M.applyKeys(keys, defaultOpts)
  for _, opts_ in ipairs(keys) do
    local opts = vim.tbl_extend('force', {}, opts_)
    local key = opts[1]; opts[1] = nil
    local cmd = opts[2]; opts[2] = nil
    local mode = opts.mode or 'n'; opts.mode = nil
    opts = vim.tbl_extend('force', {}, defaultOpts, opts)

    vim.keymap.set(mode, key, cmd, opts)
  end
end

M.init()
