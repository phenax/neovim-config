local M = {
  'numToStr/Comment.nvim',
  event = 'BufRead',
}

function M.config()
  require('Comment').setup({
    padding = true,
    toggler = {
      line = '<leader>cc',
      block = '<leader>bc',
    },
    opleader = {
      line = '<leader>c',
      block = '<leader>b',
    },
  })
end

return M
