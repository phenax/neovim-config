exec = vim.api.nvim_command
o = vim.o
g = vim.g

require "settings"
require "packer-autoload"

local modules = {
  require 'modules.theme',
  require 'modules.buffers',
  require 'modules.fs',
  require 'modules.git',
  -- require 'modules.coc',
  require 'modules.lsp',
  require 'modules.editor',
  require 'modules.notes',
  require 'modules.tools',
}

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true} -- Packer

  for _, m in pairs(modules) do
    m.plugins(use)
  end
  for _, m in pairs(modules) do
    m.configure(use)
  end
end)

