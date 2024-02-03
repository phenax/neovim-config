
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
vim.o.relativenumber = false

vim.o.showmatch = true
vim.o.ignorecase = true

vim.o.smartcase = true
vim.o.hlsearch = true
vim.o.incsearch = true
vim.o.history = 800
vim.o.undolevels = 1000
vim.o.title = true
vim.o.visualbell = true
vim.o.errorbells = false
vim.o.backspace = 'indent,eol,start'
vim.o.backup = false
vim.o.swapfile = false
vim.o.showmode = false
vim.o.ruler = true
vim.o.scrolloff = 15
vim.o.colorcolumn = '120'

-- -- Indent
vim.o.autoindent = true
vim.o.copyindent = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.smarttab = true
vim.o.expandtab = true

vim.o.laststatus = 0
vim.o.cmdheight = 1
vim.o.updatetime = 300
vim.o.signcolumn = 'yes'
vim.o.cursorline = true
vim.o.cursorcolumn = true

-- vim.o.conceallevel = 2

-- Short messages
vim.o.shortmess = vim.o.shortmess .. 'TIFc'

-- Whitespace characters
vim.o.list = true
vim.o.listchars = 'lead:.,trail:.,tab:| '
