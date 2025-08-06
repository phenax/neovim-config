return {
  keys = {
    { mode = 'n', '<leader>tt', '<cmd>TSJToggle<cr>' },
    { mode = 'n', '<leader>ts', '<cmd>TSJSplit<cr>' },
    { mode = 'n', '<leader>tj', '<cmd>TSJJoin<cr>' },
  },
  config = function()
    require('treesj').setup {
      use_default_keymaps = false,
      max_join_length = 200,
    }
  end,
}
