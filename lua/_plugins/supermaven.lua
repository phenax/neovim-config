return {
  'supermaven-inc/supermaven-nvim',
  config = function()
    require 'supermaven-nvim'.setup {
      keymaps = {
        clear_suggestion = "<C-]>",
        accept_suggestion = "<Tab>",
        accept_word = "<C-j>",
      },
      log_level = 'off',
      -- disable_inline_completion = true,
    }

    -- Disabled by default
    local api = require 'supermaven-nvim.api'
    api.stop()

    -- Toggle supermaven
    vim.keymap.set('n', '<leader>sm', function() api.toggle() end, { noremap = true })
  end,
}
