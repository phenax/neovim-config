
vim.g.mapleader = "\\"
vim.g.maplocalleader = " "

vim.o.compatible = false
vim.o.encoding = 'UTF-8'

vim.o.hidden = true
vim.o.autoread = true
vim.o.mouse = 'c'

-- Splits
vim.o.splitbelow = true
vim.o.splitright = true

vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldlevel = 50

vim.o.number = true
vim.o.relativenumber = true

-- set('showmatch', true)
-- set('ignorecase', true)
-- set('smartcase', true)
-- set('hlsearch', true)
-- set('incsearch', true)
-- set('history', 800)
-- set('undolevels', 1000)
-- set('title', true)
-- set('visualbell', true)
-- set('errorbells', false)
-- set('backspace', 'indent,eol,start')
-- set('backup', false)
-- set('swapfile', false)
-- set('noshowmode', true)
--
-- set('ruler', true)
-- set('scrolloff', 15)
-- set('colorcolumn', 120)
--
-- -- Indent
-- set('autoindent', true)
-- set('copyindent', true)
-- set('shiftwidth', 2)
-- set('tabstop', 2)
-- set('smarttab', true)
-- set('expandtab', true)
--
-- set('laststatus', 2)
-- set('cmdheight', 1)
-- set('updatetime', 300)
-- set('signcolumn', 'yes')
-- set('cursorline', true)
-- set('cursorcolumn', true)
--
-- -- Short messages
-- append('shortmess', 'TIFc')
--
