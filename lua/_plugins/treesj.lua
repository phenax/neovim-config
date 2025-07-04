local plugin = {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },

  keys = {
    { mode = 'n', '<leader>tt', '<cmd>TSJToggle<cr>' },
    { mode = 'n', '<leader>ts', '<cmd>TSJSplit<cr>' },
    { mode = 'n', '<leader>tj', '<cmd>TSJJoin<cr>' },
  },
}
function plugin.config()
  require('treesj').setup {
    use_default_keymaps = false,
    max_join_length = 200,
  }
end

return plugin
