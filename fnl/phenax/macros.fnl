;; fennel-ls: macro-file
;; [nfnl-macro]
;; TODO: move macros here somehow

(fn cmd! [cmd func opts]
  `(vim.api.nvim_create_user_command ,cmd ,func ,opts))

(fn aucmd! [ev opts]
  `(vim.api.nvim_create_autocmd ,ev ,opts))

(fn bufcmd! [buf cmd func opts]
  `(vim.api.nvim_buf_create_user_command ,buf ,cmd ,func ,opts))

(fn augroup! [name opts]
  `(vim.api.nvim_create_augroup ,name ,opts))

(fn key! [mode key action opts]
  `(vim.keymap.set ,mode ,key ,action ,opts))

(fn => [...]
  `(fn [val#] (-> val# ,...)))

(fn ?call [obj method ...]
  `(let [_val_# ,obj]
     (and _val_# (: _val_# ,method ,...))))

(fn let* [[ident value] & body]
  `(->> (fn [,ident] ,body) ,value))

{: cmd! : aucmd! : key! : => : augroup! : ?call : bufcmd! : let*}
