local M = {
  'NTBBloodbath/rest.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}

function M.config()
  require'rest-nvim'.setup({
    skip_ssl_verification = false,
  })

  vim.cmd [[command! RunHttpRequest :lua require('rest-nvim').run()]]
end

return M
