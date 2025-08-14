(import-macros {: key! : cmd! : aucmd! : =>} :phenax.macros)
(local text (require :phenax.utils.text))
(local core (require :nfnl.core))
(local fnl (require :nfnl.fennel))
(local {: fnl-path->lua-path} (require :nfnl.fs))

(local plugin {})

(fn plugin.config []
  (cmd! :Fnl (=> (. :args) plugin.run_fnl) {:nargs "*"})
  (aucmd! :FileType {:callback plugin.setup_nfnl_buf :pattern [:fennel]}))

(fn plugin.setup_nfnl_buf []
  ;; Garbage collect file
  (key! :n :<c-n>d :<cmd>NfnlDeleteOrphans<cr>)
  (key! :n :<c-n>f (fn [] (plugin.open_lua_file)))
  ;; Compile fnl code to lua in selection or para and show in floating window
  (key! [:n :x] :<c-n>h (fn [] (plugin.compile_selection_or_para_in_float)))
  ;; Execute fnl code in selection or paragraph
  (key! [:n :x] :<c-n>x (fn [] (plugin.run_selection_or_para))))

(fn plugin.run_fnl [code]
  "Evaluate fennel code in current environment"
  (->> code
       (core.str "(local core (require :nfnl.core))")
       fnl.eval
       core.println))

(fn plugin.open_lua_file []
  "Open the corresponding lua file for the current file"
  (-> (vim.fn.expand "%") fnl-path->lua-path vim.cmd.edit))

(fn plugin.compile_selection_or_para_in_float []
  "Show compiled lua code in a floating window"
  (local code (plugin.get_selection_or_paragraph))
  (local lua_code (fnl.compile-string code))
  (Snacks.win {:width 0.7
               :height 0.6
               :style :float
               :text lua_code
               :border :single
               :wo { :wrap true :number true }
               :bo { :filetype :lua }
               :keys {:q :close}}))

(fn plugin.run_selection_or_para []
  "If in selection mode, run selection as fennel code, else run current paragraph"
  (local code (plugin.get_selection_or_paragraph))
  (plugin.run_fnl code))

(fn plugin.get_selection_or_paragraph []
  "If in visual mode, use selection, Otherwise return the closest paragraph (affects gv)"
  (var old-pos nil)
  (local is-visual-mode (: (vim.fn.mode) :match "[vV]"))
  (when (not is-visual-mode)
    (set old-pos (vim.api.nvim_win_get_cursor 0))
    (vim.cmd.normal :vip))
  (vim.cmd.normal (vim.api.nvim_replace_termcodes :<esc> true false true))
  (local code (text.get_selection_text))
  (when old-pos (vim.api.nvim_win_set_cursor 0 old-pos))
  code)

plugin
