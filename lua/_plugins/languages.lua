return {
  {
    'mlochbaum/BQN',
    ft = { 'bqn' },
    config = function(plugin)
      vim.opt.rtp:append(plugin.dir .. '/editors/vim')
    end,
  },
  {
    'sputnick1124/uiua.vim',
    ft = { 'uiua' },
    config = function()
      vim.g.uiua_recommended_style = true
      vim.g.uiua_format_on_save = false
      vim.g.uiua_dark_mode = true
    end,
  },
}
