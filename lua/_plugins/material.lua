return {
  'kaicataldo/material.vim',
  dependencies = {
    'ryanoasis/vim-devicons',
    'kyazdani42/nvim-web-devicons',
  },
  branch = 'main',

  config = function()
    vim.g.material_terminal_italics = 1
    vim.g.material_theme_style = 'ocean'

    require'_settings.theme'.setup('material')
  end
}
