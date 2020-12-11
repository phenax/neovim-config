local theme = require 'modules.theme'
local buffers = require 'modules.buffers'
local fs = require 'modules.fs'

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  -- Packer
  use {'wbthomason/packer.nvim', opt = true}

  -- Theme
  theme.init(use)
  buffers.init(use)
  fs.init(use)
end)


