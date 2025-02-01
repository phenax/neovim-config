local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

require '_settings'
require('_settings.theme').setup 'default'
require 'phenax.orgmodelinks'
require 'phenax.orgmodepresent'
require 'phenax.repl'

require('lazy').setup('_plugins', {
  lockfile = vim.fn.expand '~' .. '/nixos/config/nvim/lazy.lock',
  change_detection = {
    enabled = false,
    notify = false,
  },
})
