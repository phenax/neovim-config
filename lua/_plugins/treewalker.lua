return {
  'aaronik/treewalker.nvim',
  opts = {
    highlight = true,
  },
  keys = {
    { mode = { 'n', 'v' }, '<Down>',   '<cmd>Treewalker Down<cr>',     noremap = true },
    { mode = { 'n', 'v' }, '<Up>',     '<cmd>Treewalker Up<cr>',       noremap = true },
    { mode = { 'n', 'v' }, '<Left>',   '<cmd>Treewalker Left<cr>',     noremap = true },
    { mode = { 'n', 'v' }, '<Right>',  '<cmd>Treewalker Right<cr>',    noremap = true },
    { mode = 'n',          '<C-Down>', '<cmd>Treewalker SwapDown<cr>', noremap = true },
    { mode = 'n',          '<C-Up>',   '<cmd>Treewalker SwapUp<cr>',   noremap = true },
  },
}
