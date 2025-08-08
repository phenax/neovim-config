;; fennel-ls: macro-file
;; [nfnl-macro]
;; TODO: move macros here somehow

(fn cmd! [cmd func opts]
  `(vim.api.nvim_create_user_command ,cmd ,func ,opts))

(fn aucmd! [ev opts]
  `(vim.api.nvim_create_autocmd ,ev ,opts))

(fn key! [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(fn => [...]
  `(fn [val#] (-> val# ,...)))

{: cmd! : aucmd! : key! : =>}
