(import-macros {: key! : aucmd!} :phenax.macros)

(local qf {:window_size (fn [] (math.max 4 (* vim.o.lines 0.3)))})

(fn qf.initialize []
  (key! :n :<c-c>o :<cmd>copen<cr>)
  (key! :n :<leader>xx (fn [] (vim.diagnostic.setqflist) (vim.cmd.copen)))
  (aucmd! :FileType {:callback (fn [] (qf.quickfix_window_setup))
                     :pattern [:qf]}))

(fn qf.quickfix_window_setup []
  (key! :n :q :<cmd>cclose<cr> {:buffer true :nowait true})
  (key! :n :L :<cmd>cnewer<cr> {:buffer true})
  (key! :n :H :<cmd>colder<cr> {:buffer true})
  (key! :n :C "<cmd>cexpr []<cr>" {:buffer true})
  (qf.set_qf_win_height))

(fn qf.set_qf_win_height []
  "Sets qf window height"
  (local win (vim.api.nvim_get_current_win))
  (local buf (vim.api.nvim_win_get_buf win))
  (when (= (vim.api.nvim_get_option_value :filetype {: buf}) :qf)
    (local h (math.floor (qf.window_size)))
    (vim.api.nvim_win_set_height win h)))

qf
