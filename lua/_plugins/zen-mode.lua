return {
  'folke/zen-mode.nvim',

  cmd = { 'ZenMode' },
  config = function()
    require('zen-mode').setup {
      window = {
        backdrop = 1,
        width = .50,
        height = .80,
        options = {
          signcolumn = 'no',
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = '0',
          list = false,
        },
      },
    }
  end,
}
