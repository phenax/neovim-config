return {
  'mlochbaum/BQN',
  ft = { 'bqn' },

  config = function(plugin)
    vim.opt.rtp:append(plugin.dir .. 'BQN/editors/vim')

    -- Load snippets
    require('luasnip.loaders.from_vscode').load_standalone({ path = './snippets/bqn.json' })
  end,
}
