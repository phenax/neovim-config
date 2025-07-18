vim.cmd [[autocmd BufRead,BufEnter *.bqn set filetype=bqn]]
vim.cmd [[autocmd BufRead,BufEnter *.ua set filetype=uiua]]
vim.cmd [[autocmd BufRead,BufEnter *.astro set filetype=astro]]
vim.cmd [[autocmd BufRead,BufEnter *.ts,*.tsx setlocal conceallevel=2]]

return {
  { 'sheerun/vim-polyglot' },
  {
    'mlochbaum/BQN',
    ft = { 'bqn' },
    enabled = false,
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. '/editors/vim')
    end,
  },
  {
    'sputnick1124/uiua.vim',
    ft = { 'uiua' },
    enabled = false,
    config = function()
      vim.g.uiua_recommended_style = true
      vim.g.uiua_format_on_save = false
      vim.g.uiua_dark_mode = true
    end,
  },
}
