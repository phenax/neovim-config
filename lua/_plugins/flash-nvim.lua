return {
  'folke/flash.nvim',
  event = 'VeryLazy',
  keys = {
    { '<c-b>', function() require 'flash'.jump() end,   mode = { 'n', 'i', 'v' } },
    { '<c-b>', function() require 'flash'.toggle() end, mode = 'c' },
  },
  opts = {
    labels = 'asdfghjklryuzxnm',
    label = {
      rainbow = { enabled = true, shade = 3 },
    },
    modes = {
      search = { enabled = false },
      char = {
        enabled = true,
        multi_line = false,
        highlight = { backdrop = false },
      },
    },
  },
}
