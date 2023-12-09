return {
  'cshuaimin/ssr.nvim',
  config = function()
    vim.keymap.set('n', '<leader>sr', function()
      require('ssr').open()
    end, { noremap = true, silent = true })
  end
}
