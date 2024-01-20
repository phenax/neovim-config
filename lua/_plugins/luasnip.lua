local plugin = {
  'L3MON4D3/LuaSnip',
  version = 'v2.*',
  build = 'make install_jsregexp',
  dependencies = {
    'saadparwaiz1/cmp_luasnip',
    'rafamadriz/friendly-snippets',
  },
}

function plugin.config()
  local luasnip = require 'luasnip'

  -- LuaSnip
  luasnip.filetype_extend('all', { '_' })
  require('luasnip.loaders.from_vscode').lazy_load({
    paths = {
      vim.fn.stdpath('data') .. '/lazy/friendly-snippets',
      vim.fn.stdpath('config'),
    },
  })
end

return plugin
