(local picker-history (require :phenax.snacks_picker_history))
(local sortable-buffers (require :phenax.sortable_buffers))
(local core (require :nfnl.core))
(local snacks (require :snacks))

(local m {:actions {}})
(local plugin {:config (fn [] (m.config)) :priority 100 :keys []})

(fn plugin.config []
  (snacks.setup {:bigfile {:enabled true :size (* 1 1024 1024)}
                 :bufdelete {:enabled true}
                 :gitbrowse {:enabled true}
                 :picker (m.picker_config)
                 :quickfile {:enabled true}
                 :rename {:enabled true}
                 :styles {:blame_line {:keys {:blame_term_quit {1 :q
                                                                2 (fn [self]
                                                                    (self:close))
                                                                :mode :t}
                                              :q :close}
                                       :on_win (fn [] (vim.cmd.startinsert))
                                       :position :float}
                          :phenax_git_diff {:border :single :style :blame_line}}
                 :words {:debounce 80 :enabled true :modes [:n]}}))

;; TODO: Refactor these
(set plugin.keys (core.concat (sortable-buffers.lazy_keys)
                         [{1 :<c-d> 2 (fn [] (Snacks.bufdelete)) :mode :n}
                          {1 :<c-f> 2 (fn [] (Snacks.picker.grep)) :mode :n}
                          {1 :<leader>f 2 (fn [] (m.find_files)) :mode :n}
                          {1 :<leader>sp
                           2 (fn [] (Snacks.picker.pickers))
                           :mode :n}
                          {1 :<C-_>
                           2 (fn [] (Snacks.picker.grep_buffers))
                           :mode :n}
                          {1 :<localleader>ne
                           2 (fn [] (Snacks.picker.explorer))
                           :mode :n}
                          {1 :<localleader>uu
                           2 (fn [] (Snacks.picker.undo))
                           :mode :n}
                          {1 :z= 2 (fn [] (Snacks.picker.spelling)) :mode :n}
                          {1 :<leader>tr
                           2 (fn [] (Snacks.picker.resume))
                           :mode :n}
                          {1 :<leader>qf
                           2 (fn [] (Snacks.picker.qflist))
                           :mode :n}
                          {1 :<leader>gb
                           2 (fn [] (Snacks.gitbrowse))
                           :mode [:n :v]}
                          {1 :<localleader>gbb
                           2 (fn [] (Snacks.picker.git_branches))
                           :mode :n}
                          {1 :<localleader>gbs
                           2 (fn [] (Snacks.picker.git_stash))
                           :mode :n}
                          {1 :<localleader>gm
                           2 (fn []
                               (Snacks.git.blame_line {:count (- 1)}))
                           :mode :n}
                          {1 :grr
                           2 (fn [] (Snacks.picker.lsp_references))
                           :mode :n}
                          {1 :gd
                           2 (fn [] (Snacks.picker.lsp_definitions))
                           :mode :n}
                          {1 :gt
                           2 (fn []
                               (Snacks.picker.lsp_type_definitions))
                           :mode :n}
                          {1 :<localleader>ns
                           2 (fn [] (Snacks.picker.lsp_symbols))
                           :mode :n}]))

(fn m.picker_config []
  {:enabled true
   :icons {:files {:enabled false}}
   :layout (fn []
             (local show-preview (>= vim.o.columns 120))
             {:layout {1 {:border :bottom :height 1 :win :input}
                       2 {1 {:border :none :win :list}
                          2 (or (and show-preview
                                     {:border :none
                                      :title ""
                                      :width 0.4
                                      :win :preview})
                                nil)
                          :box :horizontal}
                       :backdrop false
                       :border :top
                       :box :vertical
                       :height 0.65
                       :row (- 1)
                       :title " {title} {live} {flags}"
                       :title_pos :center
                       :width 0}})
   :on_close (fn [picker] (picker-history.save_picker picker))
   :prompt " λ "
   :ui_select true
   :win {:input {:keys (m.picker_mappings)} :list {:keys (m.picker_mappings)}}})

(fn m.picker_mappings []
  (vim.tbl_extend :force (m.select_index_keys)
                  {:<c-p> {1 :toggle_preview :mode [:i :n]}}))

(fn m.find_files []
  (if (Snacks.git.get_root) (Snacks.picker.git_files {:untracked true})
      (Snacks.picker.files)))

(fn m.select_index_keys []
  (let [keymaps {}]
    (for [i 1 10]
      (var key i)
      (when (= i 10) (set key 0))
      (tset keymaps (.. :<M- key ">")
            {1 (m.actions.highlight_index (- i 1)) :mode [:i :n]})
      (tset keymaps (tostring key)
            {1 (m.actions.open_index (- i 1)) :mode [:n]}))
    keymaps))

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
