local M = {}

function M.setup()
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
