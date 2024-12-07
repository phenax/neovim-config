return {
  'sindrets/diffview.nvim',
  keys = {
    { mode = 'n', '<leader>ggl', '<cmd>DiffviewFileHistory<cr>' },
    { mode = 'n', '<leader>ggf', '<cmd>DiffviewFileHistory %<cr>' },
    { mode = 'n', '<leader>ggo', ':DiffviewOpen ' },
  },
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  config = true,
  -- config = function()
  --   local actions = require 'diffview.actions'
  --   require 'diffview'.setup {
  --     keymaps = {
  --       file_panel = {
  --         { 'n', '<leader>j', function(foo, bar)
  --           print(vim.inspect({ foo = foo, bar = bar }))
  --         end, noremap = true },
  --       },
  --     },
  --   }
  -- end,
}
