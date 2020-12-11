local theme = require 'modules.theme'

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  -- Packer
  use {'wbthomason/packer.nvim', opt = true}

  -- Theme
  theme.plugins(use)
  theme.initialize()
end)


