-- <Tab> => Toggle mark item
-- zn => Filter marked items
-- zN => Filter unmarked items
-- z<Tab> => Clear all marks
-- <C-x> => Split
-- <C-v> => Vert split
--(builtin) ]q / [q: next/prev quickfix list
return {
  'kevinhwang91/nvim-bqf',
  ft = { 'qf' },
  config = function()
    require 'bqf'.setup {
      preview = {
        border = { '─', '─', '─', ' ', '─', '─', '─', ' ' },
      },
    }

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'qf' },
      callback = function()
        vim.keymap.set('n', 'q', '<cmd>cclose<cr>', { nowait = true })
      end,
    })
  end,
}
