(import-macros {: aucmd!} :phenax.macros)

(set vim.g.mapleader "\\")
(set vim.g.maplocalleader " ")

(set vim.opt.compatible false)
(set vim.opt.encoding :UTF-8)

(set vim.opt.hidden true)
(set vim.opt.autoread true)
(set vim.opt.mouse :c)

;; Splits
(set vim.opt.splitbelow true)
(set vim.opt.splitright true)

;; Tab
(set vim.opt.showtabline 1)
(set vim.opt.tabline "")

(set vim.opt.number true)
(set vim.opt.relativenumber true)

(set vim.opt.showmatch true)
(set vim.opt.ignorecase true)

(set vim.opt.smartcase true)
(set vim.opt.hlsearch true)
(set vim.opt.incsearch true)
(set vim.opt.history 800)
(set vim.opt.undolevels 1000)
(set vim.opt.undofile true)
(set vim.opt.title true)
(set vim.opt.visualbell true)
(set vim.opt.errorbells false)
(set vim.opt.backspace "indent,eol,start")
(set vim.opt.backup false)
(set vim.opt.swapfile false)
(set vim.opt.showmode false)
(set vim.opt.scrolloff 15)
(set vim.opt.colorcolumn :120)

;; ;; Indent
(set vim.opt.autoindent true)
(set vim.opt.copyindent true)
(set vim.opt.shiftwidth 2)
(set vim.opt.tabstop 2)
(set vim.opt.smarttab true)
(set vim.opt.expandtab true)

;; vim.o.statusline = [[%{repeat("─", winwidth(0))}]]
;set ; vim.opt.laststatus  0)
(set vim.opt.cmdheight 1)
(set vim.opt.updatetime 300)
(set vim.opt.signcolumn :yes)
(set vim.opt.cursorline true)
(set vim.opt.cursorcolumn true)
(set vim.opt.showmode true)

(set vim.opt.conceallevel 0)
(set vim.opt.concealcursor :c)

;; Short messages
(vim.opt.shortmess:append :TIc)

;; Path search
;set ; (vim.opt.path:append "**")
(set vim.opt.maxmempattern 10000)

;; Whitespace characters
(set vim.opt.list true)
;set ; (vim.opt.listchars  "lead:.,trail:.,tab:| ")
(set vim.opt.listchars {:lead "." :trail "." :tab "| "})

(set vim.g.markdown_fenced_languages [:ts=typescript :js=javascript])

;; Highlight copied text
(fn highlight_yanked_text []
  (vim.highlight.on_yank {:higroup :YankHighlight :timeout 100}))

(aucmd! :TextYankPost {:callback highlight_yanked_text})
