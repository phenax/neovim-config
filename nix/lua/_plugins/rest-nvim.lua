local M = {}

function M.setup()
  require'rest-nvim'.setup({
    skip_ssl_verification = false,
  })

  vim.cmd [[command! RunHttpRequest :lua require('rest-nvim').run()]]
end

return M
