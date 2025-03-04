return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    gitbrowse = { enabled = true },
    bufdelete = { enabled = true },
    quickfile = { enabled = true },
    rename = { enabled = true },
    bigfile = {
      enabled = true,
      size = 1 * 1024 * 1024, -- 1MB
    },
    words = {
      enabled = true,
      debounce = 80,
      modes = { 'n' },
    },
    -- image = {
    --   enabled = true,
    --   force = true,
    --   doc = {
    --     enabled = true,
    --     inline = false,
    --     float = true,
    --   }
    -- },
  },
  keys = {
    { mode = { 'n', 'v' }, '<leader>gb', function() Snacks.gitbrowse() end },
    { mode = 'n',          '<c-d>',      function() Snacks.bufdelete() end },
    { mode = 'n',          ']r',         function() Snacks.words.jump(vim.v.count1) end },
    { mode = 'n',          '[r',         function() Snacks.words.jump(-vim.v.count1) end },
  }
}
