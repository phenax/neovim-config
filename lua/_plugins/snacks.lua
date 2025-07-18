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
    bigfile = { enabled = true, size = 1 * 1024 * 1024 },
    words = { enabled = true, debounce = 80, modes = { 'n' } },
  },
  keys = {
    { mode = { 'n', 'v' }, '<leader>gb', function() Snacks.gitbrowse() end },
    { mode = 'n',          '<c-d>',      function() Snacks.bufdelete() end },
  }
}
