-- <Tab> => Toggle mark item
-- zn => Filter marked items
-- zN => Filter unmarked items
-- z<Tab> => Clear all marks
-- <C-x> => Split
-- <C-v> => Vert split
return {
  'kevinhwang91/nvim-bqf',
  ft = { 'qf' },
  config = function()
    require 'bqf'.setup {
      preview = {
        border = { '─', '─', '─', ' ', '─', '─', '─', ' ' },
        winblend = 0,
      },
    }
  end,
}
