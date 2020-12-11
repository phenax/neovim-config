local theme = require 'modules.theme'
local buffers = require 'modules.buffers'
local fs = require 'modules.fs'
local coc = require 'modules.coc'

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  -- Packer
  use {'wbthomason/packer.nvim', opt = true}

  -- Theme
  theme.init(use)
  buffers.init(use)
  fs.init(use)
  coc.init(use)
end)


