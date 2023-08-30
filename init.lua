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
    require 'modules.buffers',  -- migrated
    require 'modules.fs',  -- migrated
    require 'modules.git', -- migrated
    require 'modules.editor', -- migrated
    require 'modules.lsp',
    require 'modules.tools', -- migrated
    require 'modules.notes', -- started but paused
    -- require 'modules.coc',
  }

  for _, m in pairs(modules) do
    m.plugins(use)
  end
  for _, m in pairs(modules) do
    m.configure(use)
  end
end)

