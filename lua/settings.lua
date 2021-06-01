local utils = require 'utils'
local set = utils.set
local append = utils.append

-- Leader keys
g.mapleader = "\\"
g.maplocalleader = " "

set('compatible', false)
set('encoding', 'UTF-8')

set('hidden', true)
set('autoread', true)
set('mouse', 'c')

set('splitbelow', true)
set('splitright', true)


-- TODO: Fix code folding
exec [[set foldmethod=expr]]
exec [[set foldexpr=nvim_treesitter#foldexpr()]]
exec [[set foldlevel=100]]


set('autoindent', true)
set('copyindent', true)
set('showmatch', true)
set('ignorecase', true)
set('smartcase', true)
set('smarttab', true)
set('hlsearch', true)
set('incsearch', true)
set('history', 800)
set('undolevels', 1000)
set('title', true)
set('visualbell', true)
set('errorbells', false)
set('backspace', 'indent,eol,start')
set('backup', false)
set('swapfile', false)
set('noshowmode', true)

set('number', true)
set('relativenumber', true)
set('ruler', true)
set('tabstop', 2)
set('shiftwidth', 2)
set('smarttab', true)
set('expandtab', true)
set('scrolloff', 15)
set('colorcolumn', 120)

set('laststatus', 2)
set('cursorline', true)
set('cmdheight', 1)
set('updatetime', 300)
set('signcolumn', 'yes')

-- Short messages
append('shortmess', 'TIFc')

