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
vim.opt.foldenable = false
-- Hack to force fold re-evaluation and to use ts for all folding
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if vim.o.filetype == 'org' then
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
    else
      vim.opt_local.foldexpr = vim.opt_local.foldexpr
    end
    vim.opt_local.foldlevel = 50
    vim.opt_local.foldenable = false
  end
})

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
vim.opt.scrolloff = 15
vim.opt.colorcolumn = '120'

-- -- Indent
vim.opt.autoindent = true
vim.opt.copyindent = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.smarttab = true
vim.opt.expandtab = true

vim.opt.ruler = true
vim.o.statusline = [[%{repeat('─', winwidth(0))}]]
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
