(import-macros {: key! : aucmd!} :phenax.macros)
(local {: not_nil?} (require :phenax.utils.utils))
(local core (require :nfnl.core))

(local qf {:window_size (fn [] (math.max 4 (* vim.o.lines 0.3)))
           :item-previewers {}})

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
  (key! :n :p (fn [] (qf.preview)) {:buffer true})
  (qf.set_qf_win_height))

(fn qf.set_qf_win_height []
  "Sets qf window height"
  (local win (vim.api.nvim_get_current_win))
  (local buf (vim.api.nvim_win_get_buf win))
  (when (= (vim.api.nvim_get_option_value :filetype {: buf}) :qf)
    (local h (math.floor (qf.window_size)))
    (vim.api.nvim_win_set_height win h)))

(fn qf.default-previewer [item _index]
  (Snacks.win {:style :split
               :fixbuf true
               :file (or item.filename (vim.fn.bufname item.bufnr))
               :minimal false
               :on_win (fn [win]
                         (vim.api.nvim_win_set_cursor win.win
                                                      [(or item.lnum 0)
                                                       (or item.col 0)]))
               :keys {:q :close}}))

(fn qf.preview []
  (local index (vim.fn.line "."))
  (local qfitem (. (vim.fn.getqflist) index))
  (local preview-type (?. qfitem :user_data :preview_type))
  (var previewer qf.default-previewer)
  (when (not_nil? preview-type)
    (local p (. qf.item-previewers preview-type))
    (when (core.function? p) (set previewer p)))
  (previewer qfitem index))

(fn qf.add-item-previewer [preview_type preview]
  (tset qf.item-previewers preview_type preview))

qf
