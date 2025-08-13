(import-macros {: key!} :phenax.macros)
(local picker-history (require :phenax.snacks_picker_history))
(local core (require :nfnl.core))
(local {: ++} (require :phenax.utils.utils))
(local snacks (require :snacks))

(local m {:actions {}})
(local plugin {:config (fn [] (m.config)) :priority 100})

(fn plugin.config []
  (key! :n :<c-d> (fn [] (Snacks.bufdelete)))
  (key! :n :<c-f> (fn [] (Snacks.picker.grep)))
  (key! :n :<leader>f (fn [] (m.find_files)))
  (key! :n :<leader>sp (fn [] (Snacks.picker.pickers)))
  (key! :n :<C-_> (fn [] (Snacks.picker.grep_buffers)))
  (key! :n :<localleader>ne (fn [] (Snacks.picker.explorer)))
  (key! :n :<localleader>uu (fn [] (Snacks.picker.undo)))
  (key! :n :z= (fn [] (Snacks.picker.spelling)))
  (key! :n :<leader>tr (fn [] (Snacks.picker.resume)))
  (key! :n :<leader>qf (fn [] (Snacks.picker.qflist)))
  (key! [:n :v] :<leader>gb (fn [] (Snacks.gitbrowse)))
  (key! :n :<localleader>gbb (fn [] (Snacks.picker.git_branches)))
  (key! :n :<localleader>gbs (fn [] (Snacks.picker.git_stash)))
  (key! :n :<localleader>gm
        (fn []
          (Snacks.git.blame_line {:count (- 1)})))
  (key! :n :grr (fn [] (Snacks.picker.lsp_references)))
  (key! :n :gd (fn [] (Snacks.picker.lsp_definitions)))
  (key! :n :gt (fn [] (Snacks.picker.lsp_type_definitions)))
  (key! :n :<localleader>ns (fn [] (Snacks.picker.lsp_symbols)))
  ;; Setup
  (lambda quit [self] (self:close))
  (local blame_line_keys {:q quit :blame_term_quit (++ [:q quit] {:mode :t})})
  (lambda on_blame_line_win [win]
    (set (. vim.bo win.scratch_buf :filetype) :git)
    (vim.cmd.startinsert))
  (snacks.setup {:bigfile {:enabled true :size (* 1 1024 1024)}
                 :bufdelete {:enabled true}
                 :gitbrowse {:enabled true}
                 :picker (m.picker_config)
                 :quickfile {:enabled true}
                 :rename {:enabled true}
                 :styles {:phenax_git_diff {:border :single :style :blame_line}
                          :blame_line {:keys blame_line_keys
                                       :on_win on_blame_line_win
                                       :position :float}}
                 :words {:debounce 80 :enabled true :modes [:n]}}))

(fn m.picker_config []
  {:enabled true
   :icons {:files {:enabled false}}
   :layout (fn []
             (local show-preview (>= vim.o.columns 120))
             (local preview-box {:border :none
                                 :title ""
                                 :width 0.4
                                 :win :preview})
             {:layout (++ [{:border :bottom :height 1 :win :input}
                           (++ [{:border :none :win :list}
                                (if show-preview preview-box nil)]
                               {:box :horizontal})]
                          {:backdrop false
                           :border :top
                           :box :vertical
                           :height 0.65
                           :row (- 1)
                           :title " {title} {live} {flags}"
                           :title_pos :center
                           :width 0})})
   :formatters {:file {:filename_first true :truncate math.huge}}
   :on_close (fn [picker] (picker-history.save_picker picker))
   :prompt " λ "
   :ui_select true
   :win {:input {:keys (m.picker_mappings)} :list {:keys (m.picker_mappings)}}})

(fn m.picker_mappings []
  (fn keys-for-index [index]
    (local key (if (= index 10) 0 index))
    (lambda alt [k] (.. :<M- k ">"))
    {(alt key) (++ [(m.actions.highlight_index (- index 1))] {:mode [:i :n]})
     (tostring key) (++ [(m.actions.open_index (- index 1))] {:mode [:n]})})

  (fn select-index-keys []
    (local keymaps (fcollect [i 1 10] (keys-for-index i)))
    (core.reduce core.merge {} keymaps))

  (++ (select-index-keys) {:<c-p> (++ [:toggle_preview] {:mode [:i :n]})}))

(fn m.find_files []
  (if (Snacks.git.get_root) (Snacks.picker.git_files {:untracked true})
      (Snacks.picker.files)))

(fn m.actions.highlight_index [index]
  (fn []
    (let [picker (m.current_picker)]
      (when (not picker) (lua "return "))
      (picker.list:_move (+ (- index picker.list.cursor) 1)))))

(fn m.actions.open_index [index]
  (fn []
    (let [picker (m.current_picker)]
      (when (not picker) (lua "return "))
      (picker.list:_move (+ (- index picker.list.cursor) 1))
      (picker:action :confirm))))

(fn m.current_picker [] (. (Snacks.picker.get) 1))

plugin
