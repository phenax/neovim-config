local utils = require 'utils'
local nmap = utils.nmap
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
set('foldmethod', 'expr')
set('foldexpr', 'nvim_treesitter#foldexpr()')
set('foldlevel', 50)

set('showmatch', true)
set('ignorecase', true)
set('smartcase', true)
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
set('scrolloff', 15)
set('colorcolumn', 120)

-- Indent
set('autoindent', true)
set('copyindent', true)
set('shiftwidth', 2)
set('tabstop', 2)
set('smarttab', true)
set('expandtab', true)

set('laststatus', 2)
set('cmdheight', 1)
set('updatetime', 300)
set('signcolumn', 'yes')
set('cursorline', true)
set('cursorcolumn', true)

-- Short messages
append('shortmess', 'TIFc')

