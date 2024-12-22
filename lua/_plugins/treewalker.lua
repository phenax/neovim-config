return {
  'aaronik/treewalker.nvim',
  opts = {
    highlight = true,
  },
  keys = {
    { mode = 'n', '<Down>',  '<cmd>Treewalker Down<cr>',  noremap = true },
    { mode = 'n', '<Up>',    '<cmd>Treewalker Up<cr>',    noremap = true },
    { mode = 'n', '<Left>',  '<cmd>Treewalker Left<cr>',  noremap = true },
    { mode = 'n', '<Right>', '<cmd>Treewalker Right<cr>', noremap = true },
  },
}
