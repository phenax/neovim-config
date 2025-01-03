return {
  'folke/flash.nvim',
  keys = {
    { '<c-b>', function() require('flash').jump() end,   mode = { 'n', 'i', 'v' } },
    { '<c-b>', function() require('flash').toggle() end, mode = 'c' },
  },
  opts = {
    labels = 'asdfhjklqwertyuiop',
    label = {
      rainbow = { enabled = true, shade = 3 },
      after = true,
      uppercase = false,
      -- distance = false,
      -- reuse = 'none',
    },
    modes = {
      search = { enabled = false },
      char = {
        enabled = false,
        multi_line = false,
        highlight = { backdrop = false },
      },
    },
  },
}
