-- Highlight words
return {
  'RRethy/vim-illuminate',
  event = 'BufReadPost',
  enabled = false,
  keys = {
    { mode = 'n', ']r', function() require('illuminate').goto_next_reference(true) end },
    { mode = 'n', '[r', function() require('illuminate').goto_prev_reference(true) end },
  },
  config = function()
    require('illuminate').configure {
      providers = { 'lsp', 'treesitter', 'regex' },
      large_file_cutoff = 1000,
    }
  end,
}
