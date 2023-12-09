exec = vim.api.nvim_command
o = vim.o
g = vim.g

require "settings"
require "packer-autoload"

vim.cmd [[packadd packer.nvim]]

local packer = require('packer')
return packer.startup(function()
  use {'wbthomason/packer.nvim', opt = true} -- Packer
  -- use 'dstein64/vim-startuptime'

  local modules = {
    require 'modules.theme',
    require 'modules.buffers',
    require 'modules.fs',
    require 'modules.git',
    require 'modules.editor',
    require 'modules.lsp',
    require 'modules.tools',
    require 'modules.notes',
    -- require 'modules.coc',
  }

  for _, m in pairs(modules) do
    m.plugins(use)
  end
  for _, m in pairs(modules) do
    m.configure(use)
  end
end)

