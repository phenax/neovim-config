local M = {
  'NvChad/nvim-colorizer.lua',
}

function M.config()
  require'colorizer'.setup({
    user_default_options = {
      tailwind = true,
    },
  })
end

return M
