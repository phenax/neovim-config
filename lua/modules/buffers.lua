local utils = require 'utils'
local nmap = utils.nmap
local nnoremap = utils.nnoremap

local buffers = {}

function buffers.plugins(use)
  use 'qpkorr/vim-bufkill'
end

function buffers.configure()
  -- Buffer manipulation
  nmap('<C-d>', ':BD<CR>')

  -- Buffer navigation
  nmap('<localleader>bb', ':Telescope buffers<cr>')
  nmap('<localleader><tab>', ':b#<cr>') -- Toggle between buffers
  nmap('<C-k>', ':bp<CR>')
  nmap('<C-j>', ':bn<CR>')

  -- Go to nth buffer
  nmap('<localleader>1', ':LualineBuffersJump! 1<CR>') 
  nmap('<localleader>2', ':LualineBuffersJump! 2<CR>')
  nmap('<localleader>3', ':LualineBuffersJump! 3<CR>')
  nmap('<localleader>4', ':LualineBuffersJump! 4<CR>')
  nmap('<localleader>5', ':LualineBuffersJump! 5<CR>')
  nmap('<localleader>6', ':LualineBuffersJump! 6<CR>')
  nmap('<localleader>7', ':LualineBuffersJump! 7<CR>')
  nmap('<localleader>8', ':LualineBuffersJump! 8<CR>')
  nmap('<localleader>9', ':LualineBuffersJump! 9<CR>')
  nmap('<localleader>0', ':LualineBuffersJump! 10<CR>')

  -- Split window navigation
  nmap('<M-h>', '<C-w>h')
  nmap('<M-l>', '<C-w>l')
  nmap('<M-k>', '<C-w>k')
  nmap('<M-j>', '<C-w>j')
end

return buffers
