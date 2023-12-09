return {
  'drybalka/tree-climber.nvim',

  keys = {
    { mode = {'n', 'v', 'o'},  'H',     function() require('tree-climber').goto_prev() end },
    { mode = {'n', 'v', 'o'},  'L',     function() require('tree-climber').goto_next() end },
    { mode = 'n',              '<c-h>', function() require('tree-climber').swap_prev() end },
    { mode = 'n',              '<c-l>', function() require('tree-climber').swap_next() end },
  }
}
