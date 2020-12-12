local utils = require 'utils'
local nmap = utils.nmap

local buffers = {}

function buffers.plugins(use)
  use 'qpkorr/vim-bufkill'
end

function buffers.configure()
  -- Buffer manipulation
  nmap('<C-d>', ':BD<CR>')

  -- Buffer navigation
  nmap('<C-k>', ':bp<CR>')
  nmap('<C-j>', ':bn<CR>')
  nmap('<localleader>1', '<Plug>lightline#bufferline#go(1)')
  nmap('<localleader>2', '<Plug>lightline#bufferline#go(2)')
  nmap('<localleader>3', '<Plug>lightline#bufferline#go(3)')
  nmap('<localleader>4', '<Plug>lightline#bufferline#go(4)')
  nmap('<localleader>5', '<Plug>lightline#bufferline#go(5)')
  nmap('<localleader>6', '<Plug>lightline#bufferline#go(6)')
  nmap('<localleader>7', '<Plug>lightline#bufferline#go(7)')
  nmap('<localleader>8', '<Plug>lightline#bufferline#go(8)')
  nmap('<localleader>9', '<Plug>lightline#bufferline#go(9)')
  nmap('<localleader>0', '<Plug>lightline#bufferline#go(10)')

  -- Split window navigation
  nmap('<M-h>', '<C-w>h')
  nmap('<M-l>', '<C-w>l')
  nmap('<M-k>', '<C-w>k')
  nmap('<M-j>', '<C-w>j')
end

function buffers.init(use)
  buffers.plugins(use)
  buffers.configure()
end

return buffers
