local plugin = {
  'Wansmer/treesj',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },

  keys = {
    { mode = 'n', '<leader>tt', ':TSJToggle<cr>' },
    { mode = 'n', '<leader>ts', ':TSJSplit<cr>' },
    { mode = 'n', '<leader>tj', ':TSJJoin<cr>' },
  },
}
function plugin.config()
  require('treesj').setup {
    use_default_keymaps = false,
    max_join_length = 200,
  }
end

return plugin
