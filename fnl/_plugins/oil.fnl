(import-macros {: key!} :phenax.macros)
(local oil (require :oil))
(local core (require :nfnl.core))
(local {: present?} (require :phenax.utils.utils))

(local m {})
(local plugin {:config (fn [] (m.setup))})

(local oil_keys {:<C-p> {1 :actions.preview :mode :n}
                 :<C-y> {1 (fn [] (m.copy_path {:absolute true})) :mode :n}
                 :<CR> {1 :actions.select :mode [:n :v]}
                 :<c-d> {1 :actions.close :mode :n}
                 :<c-l> (fn [] (set vim.bo.buflisted (not vim.bo.buflisted)))
                 :<c-q> {1 (fn []
                             ((. (require :oil.util) :send_to_quickfix) {:action :r
                                                                         :target :quickfix})
                             (vim.cmd.copen))
                         :mode :n}
                 :<c-t><c-t> {1 :actions.open_terminal :mode :n}
                 "<localleader>:" {1 :actions.open_cmdline
                                   :mode :n
                                   :opts {:shorten_path false}}
                 :H {1 :actions.parent :mode :n}
                 :J {1 :j :remap true}
                 :K {1 :k :remap true}
                 :L {1 :actions.select :mode :n}
                 :R {1 :actions.refresh :mode :n}
                 :Y {1 (fn [] (m.copy_path {:absolute false})) :mode :n}
                 :cd {1 :actions.cd :mode :n}
                 :g? {1 :actions.show_help :mode :n}
                 :gs {1 :actions.change_sort :mode :n}
                 :gx {1 :actions.open_external :mode :n}
                 "~" {1 :actions.open_cwd :mode :n}})

(fn m.setup []
  (key! :n :<localleader>nn :<cmd>Oil<cr>)
  (oil.setup {:buf_options {:bufhidden :hide :buflisted false}
              :columns [:permissions :type :size]
              :constrain_cursor :name
              :default_file_explorer true
              :delete_to_trash false
              :keymaps oil_keys
              :lsp_file_methods {:enabled true}
              :use_default_keymaps false
              :view_options {:case_insensitive true
                             :is_always_hidden (fn [name]
                                                 (= name ".."))
                             :show_hidden true}
              :win_options {:winbar "%!v:lua._OilWinbarSegment()"}}))

(fn m.get_cursor_path []
  (local fname (-> (oil.get_cursor_entry) (. :parsed_name)))
  (vim.fs.joinpath (oil.get_current_dir) fname))

(fn m.copy_path [opts]
  "Copy path to clipboard. If opts.absolute is true, copies absolute path"
  (local modify (if (and opts opts.absolute) ":p" ":~:."))
  (local path (vim.fn.fnamemodify (m.get_cursor_path) modify))
  (vim.fn.setreg "+" path)
  (vim.notify (.. "Copied to clipboard: " path) vim.log.levels.INFO
              {:title :oil}))

(fn _G._OilWinbarSegment []
  "Winbar contents for oil buffers"
  (local bufnr (vim.api.nvim_win_get_buf vim.g.statusline_winid))
  (local dir (oil.get_current_dir bufnr))
  (local short-path (vim.fn.fnamemodify (or dir "") ":~:."))
  (if (core.empty? dir) (vim.api.nvim_buf_get_name 0)
      (present? short-path) (.. "…/" short-path)
      (vim.fn.fnamemodify dir ":~")))

plugin
