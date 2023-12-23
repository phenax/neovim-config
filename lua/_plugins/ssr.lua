return {
  'cshuaimin/ssr.nvim',
  keys = {
    {
      mode = 'n',
      '<leader>sr',
      function() require('ssr').open() end,
    },
  },
}
