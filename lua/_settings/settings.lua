vim.g.mapleader = '\\'
vim.g.maplocalleader = ' '

vim.opt.compatible = false
vim.opt.encoding = 'UTF-8'

vim.opt.hidden = true
vim.opt.autoread = true
vim.opt.mouse = 'c'

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 50

vim.opt.number = true
vim.opt.relativenumber = false

vim.opt.showmatch = true
vim.opt.ignorecase = true

vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.history = 800
vim.opt.undolevels = 1000
vim.opt.undofile = true
vim.opt.title = true
vim.opt.visualbell = true
vim.opt.errorbells = false
vim.opt.backspace = 'indent,eol,start'
vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.showmode = false
vim.opt.ruler = true
vim.opt.rulerformat = '%30(%=%l/%L, %v %#RulerHighlighted#%y%<%)'
vim.opt.scrolloff = 15
vim.opt.colorcolumn = '120'

-- -- Indent
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smarttab = true
vim.opt.expandtab = true

vim.opt.laststatus = 0
vim.opt.cmdheight = 1
vim.opt.updatetime = 300
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.cursorcolumn = true
vim.opt.showmode = true

vim.opt.conceallevel = 0
vim.opt.concealcursor = 'c'

-- Short messages
vim.opt.shortmess:append 'TIc'

-- Whitespace characters
vim.opt.list = true
-- vim.opt.listchars = 'lead:.,trail:.,tab:| '
vim.opt.listchars = {
  lead = '.',
  trail = '.',
  tab = '| ',
}
