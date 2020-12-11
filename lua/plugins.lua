local execute = vim.api.nvim_command
local fn = vim.fn
local theme = require "theme"

vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
  -- Packer
  use {'wbthomason/packer.nvim', opt = true}

  -- Theme
  theme.plugins(use)
  theme.initialize()
end)


