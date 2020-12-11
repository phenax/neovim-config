local utils = require 'utils'

-- Leader keys
g.mapleader = "\\"
g.maplocalleader = " "


utils.set('hidden', true)
utils.set('autoread', true)
utils.set('mouse', 'c')

utils.set('splitbelow', true)
utils.set('splitright', true)


-- TODO: Fix code folding
utils.set('foldenable', true)
utils.set('foldmethod', 'marker')
utils.set('foldcolumn', '2')
utils.set('foldopen', 'mark')

utils.set('autoindent', true)
utils.set('copyindent', true)
utils.set('showmatch', true)
utils.set('ignorecase', true)
utils.set('smartcase', true)
utils.set('smarttab', true)
utils.set('hlsearch', true)
utils.set('incsearch', true)
utils.set('history', 800)
utils.set('undolevels', 1000)
utils.set('title', true)
utils.set('visualbell', true)
utils.set('errorbells', false)
utils.set('backspace', 'indent,eol,start')
utils.set('backup', false)
utils.set('swapfile', false)
utils.set('noshowmode', true)

utils.set('number', true)
utils.set('relativenumber', true)
utils.set('ruler', true)
utils.set('tabstop', 2)
utils.set('shiftwidth', 2)
utils.set('smarttab', true)
utils.set('expandtab', true)

utils.set('laststatus', 2)
utils.set('cursorline', true)
utils.set('cmdheight', 1)
utils.set('updatetime', 300)
utils.set('shortmess', 'c')
utils.set('signcolumn', 'yes')

