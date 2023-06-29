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
  exec [[ command! CloseAll :%bd|e#|bd#|'" ]] -- Delete all buffers except for the current one
  nmap('<leader>ca', [[ :CloseAll ]])

  -- Buffer navigation
  nmap('<localleader>b', ':Telescope buffers<CR>')
  nmap('<C-_>', ':Telescope current_buffer_fuzzy_find<CR>')
  nmap('<localleader><tab>', ':b#<CR>')
  -- nmap('<C-k>', ':bp<CR>')
  -- nmap('<C-j>', ':bn<CR>')

  -- Go to nth buffer
  for i = 0, 9 do
    local bidx = i
    if (i == 0) then bidx = 10 end
    nmap('<localleader>' .. i, ':LualineBuffersJump! '.. bidx ..'<CR>')
  end

  -- Split window navigation
  nmap('<M-h>', '<C-w>h')
  nmap('<M-l>', '<C-w>l')
  nmap('<M-k>', '<C-w>k')
  nmap('<M-j>', '<C-w>j')
end

return buffers
