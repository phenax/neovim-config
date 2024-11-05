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
      layout = {
        min_width = 40,
        resize_to_content = false,
        preserve_equality = true,
      }
    }
  end,
}
