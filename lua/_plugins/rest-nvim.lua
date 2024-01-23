return {
  'NTBBloodbath/rest.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },

  config = function()
    require'rest-nvim'.setup({
      skip_ssl_verification = false,
    })

    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = { "*.http" },
      callback = function()
        vim.cmd [[command! RunHttp :lua require('rest-nvim').run()]]
        vim.keymap.set('n', '<CR>', ':lua require"rest-nvim".run()<CR>', { buffer = true })
      end,
    })
  end,
}
