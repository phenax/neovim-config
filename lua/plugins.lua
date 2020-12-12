local modules = {
  require 'modules.theme',
  require 'modules.buffers',
  require 'modules.fs',
  require 'modules.coc',
  require 'modules.git',
  require 'modules.ide',
}

vim.cmd [[packadd packer.nvim]]
return require('packer').startup(function()
  use {'wbthomason/packer.nvim', opt = true} -- Packer

  for _, m in pairs(modules) do
    m.init(use)
  end
end)

