return {
  keys = {
    -- TODO: if arrow key fails, do regular arrow key fallback
    { mode = { 'n', 'v' }, '<Down>',   '<cmd>Treewalker Down<cr>',     noremap = true },
    { mode = { 'n', 'v' }, '<Up>',     '<cmd>Treewalker Up<cr>',       noremap = true },
    { mode = { 'n', 'v' }, '<Left>',   '<cmd>Treewalker Left<cr>',     noremap = true },
    { mode = { 'n', 'v' }, '<Right>',  '<cmd>Treewalker Right<cr>',    noremap = true },
    { mode = 'n',          '<C-Down>', '<cmd>Treewalker SwapDown<cr>', noremap = true },
    { mode = 'n',          '<C-Up>',   '<cmd>Treewalker SwapUp<cr>',   noremap = true },
  },
  config = function()
    require 'treewalker'.setup {
      highlight = true,
    }
  end,
}
