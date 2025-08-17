(import-macros {: key! : aucmd!} :phenax.macros)
(local {: not_nil?} (require :phenax.utils.utils))
(local text (require :phenax.utils.text))
(local core (require :nfnl.core))

(local qf {:window_size (fn [] (math.max 4 (* vim.o.lines 0.3)))
           :item-previewers {}})

(fn qf.initialize []
  (key! :n :<c-c>o :<cmd>copen<cr>)
  (key! :n :<leader>xx (fn [] (vim.diagnostic.setqflist) (vim.cmd.copen)))
  (aucmd! :FileType
          {:pattern [:qf]
           :callback (fn [opts] (qf.quickfix-buf-setup opts.buf))}))

(fn qf.quickfix-buf-setup [buf]
  (key! :n :q :<cmd>cclose<cr> {:buffer buf :nowait true})
  (key! :n :<c-r> :<cmd>cnewer<cr> {:buffer buf})
  (key! :n :u :<cmd>colder<cr> {:buffer buf})
  (key! [:n :x] :dd qf.delete-items {:buffer buf})
  (key! :n :C "<cmd>cexpr []<cr>" {:buffer buf})
  (key! :n :p qf.preview {:buffer buf})
  (qf.set_qf_win_height))

(fn qf.add-item-previewer [preview_type preview]
  (tset qf.item-previewers preview_type preview))

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
                                                       (- (or item.col 0) 1)]))
               :keys {:q :close}}))

(fn qf.preview []
  "Preview (p key) action to trigger custom preview for text"
  (local index (vim.fn.line "."))
  (local qfitem (. (vim.fn.getqflist) index))
  (local preview-type (?. qfitem :user_data :preview_type))
  (var previewer qf.default-previewer)
  (when (not_nil? preview-type)
    (local p (. qf.item-previewers preview-type))
    (when (core.function? p) (set previewer p)))
  (previewer qfitem index))

(fn qf.delete-items []
  "Delete item under cursor or visual selected lines from quickfix list
  Note: Selects current line if not in visual mode so affects gv"
  (local visual-mode? (: (vim.fn.mode) :match "[vV]"))
  (when (not visual-mode?) (vim.cmd.normal :V))
  (local (line-start col-start line-end _) (text.get_selection_range))
  (local qflist (vim.fn.getqflist))
  (for [index line-end line-start -1]
    (table.remove qflist index))
  (vim.fn.setqflist qflist)
  (pcall vim.api.nvim_win_set_cursor 0
         [(math.min line-start (length qflist)) col-start]))

qf
