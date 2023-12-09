return {
  'cshuaimin/ssr.nvim',
  config = {
    keys = {
      {
        mode = 'n',
        '<leader>sr',
        function() require('ssr').open() end,
      },
    },
  },
}
