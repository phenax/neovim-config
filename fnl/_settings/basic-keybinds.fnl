;; Tab/buffer management
(vim.keymap.set :n :<leader>qq :<cmd>tabclose<cr>)
(vim.keymap.set :n :<localleader><tab> ":b#<CR>")
(vim.cmd "command! CloseAll :%bd|e#|bd#|'\"")

;; Window navigation
(vim.keymap.set :n :<M-h> :<C-w>h)
(vim.keymap.set :n :<M-l> :<C-w>l)
(vim.keymap.set :n :<M-k> :<C-w>k)
(vim.keymap.set :n :<M-j> :<C-w>j)

;; Prevent accidents
(vim.cmd "map q: <Nop>")
(vim.cmd "nnoremap Q <nop>")
(vim.cmd "nnoremap S <nop>")
(vim.cmd "command! W :w")
(vim.cmd "command! Q :q")
(vim.cmd "command! Qa :qa")

;; Selection movement
(vim.cmd "xnoremap <  <gv")
(vim.cmd "xnoremap >  >gv")
(vim.keymap.set :v :K ":m '<-2<CR>gv=gv" {:noremap true :silent true})
(vim.keymap.set :v :J ":m '>+1<CR>gv=gv" {:noremap true :silent true})

;; Normie binds
(vim.keymap.set :n :<C-s> :<cmd>w<cr> {:noremap true :silent true})
(vim.keymap.set :v :<C-c> "\"+y")

;; Manage indentation
(fn _G.SetIndent [indent]
  (vim.cmd (.. ":set shiftwidth=" indent " expandtab")))

;; Terminal mode escape key
(vim.keymap.set :t :<Esc> "<C-\\><C-n>" {:noremap true})

;; Text case convertion (camelCase | underscore_case)
(vim.keymap.set :x :<leader>cc ":<c-u>s#\\%V[_]\\+\\(.\\)#\\U\\1#g<cr>")
(vim.keymap.set :x :<leader>cu ":<c-u>s#\\%V[A-Z]\\+#_\\l\\0#g<cr>")

;; Sessions
(vim.keymap.set :n :<leader>sw ":mksession! .vim.session<cr>")
(vim.keymap.set :n :<leader>sl ":source .vim.session<cr>")

;; Sort selection
(vim.keymap.set :v :gs ":sort<cr>")

;; Open command buffer
(vim.keymap.set :n "g;" ":<c-f>i")

;; Toggle spell check
(vim.keymap.set :n :<leader>== ":setlocal spell! spelllang=en_us<CR>")

;; Set ft
(vim.keymap.set :n :<leader>cf ":set filetype=")

