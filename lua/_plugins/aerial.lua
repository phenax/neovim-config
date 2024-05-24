return {
  'stevearc/aerial.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },
  keys = {
    { '<localleader>ns', ':AerialToggle right<cr>', mode = 'n' },
    { '<localleader>nt', ':AerialNavToggle<cr>',    mode = 'n' },
  },

  config = function()
    require('aerial').setup {
      disable_max_lines = 30000,
    }
  end,
}
