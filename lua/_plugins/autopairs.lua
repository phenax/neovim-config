return {
  'windwp/nvim-autopairs',
  dependencies = {
    'hrsh7th/nvim-cmp',
  },
  event = 'InsertEnter',
  config = function()
    require('nvim-autopairs').setup {
      disable_filetype = { 'TelescopePrompt' },
    }

    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    require('cmp').event:on(
      'confirm_done',
      cmp_autopairs.on_confirm_done {
        map_char = { tex = '' },
      }
    )
  end,
}
