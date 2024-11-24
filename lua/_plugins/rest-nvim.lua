vim.g.rest_nvim = {
  request = {
    skip_ssl_verification = false,
    hooks = {
      set_content_type = true,
    },
  },
}

return {
  'rest-nvim/rest.nvim',
  dependencies = {
    -- 'vhyrro/luarocks.nvim',
    'nvim-lua/plenary.nvim',
  },

  version = 'v1.2.1',

  ft = { 'http' },

  config = function()
    local rest_nvim = require 'rest-nvim'
    rest_nvim.setup {
      skip_ssl_verification = false,
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'http',
      callback = function()
        vim.keymap.set('n', '<CR>', rest_nvim.run, { buffer = true })
        -- vim.keymap.set('n', '<CR>', '<cmd>Rest run<cr>', { buffer = true })
      end,
    })
  end,
}
