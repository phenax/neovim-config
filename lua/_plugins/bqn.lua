return {
  'mlochbaum/BQN',
  ft = { 'bqn' },

  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. '/editors/vim')

    -- Load snippets
    -- TODO: Only load on buffer
    require('luasnip.loaders.from_vscode').load_standalone({ path = './snippets/bqn.json' })
  end,
}
