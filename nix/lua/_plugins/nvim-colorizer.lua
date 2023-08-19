local M = {}

function M.setup()
  require'colorizer'.setup({
    user_default_options = {
      tailwind = true,
    },
  })
end

return M
