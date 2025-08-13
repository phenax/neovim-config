(import-macros {: key! : cmd! : aucmd! : =>} :phenax.macros)
(local text (require :phenax.utils.text))
(local core (require :nfnl.core))
(local fnl (require :nfnl.fennel))
(local {: fnl-path->lua-path} (require :nfnl.fs))

(local plugin {})

(fn plugin.config []
  (cmd! :Fnl (=> (. :args) plugin.run_fnl) {:nargs "*"})
  (aucmd! :FileType {:callback plugin.setup_nfnl_buf
                     :pattern [:fennel]}))

(fn plugin.setup_nfnl_buf []
  ;; Garbage collect file
  (key! :n :<c-n>d :<cmd>NfnlDeleteOrphans<cr>)
  (key! :n :<c-n>f
        (fn []
          (vim.cmd.edit (fnl-path->lua-path (vim.fn.expand "%")))))
  ;; Execute current paragraph
  (key! :n :<c-n>x (fn [] (plugin.run_selection_or_paragraph))))

(fn plugin.run_fnl [code]
  "Evaluate fennel code in current environment"
  (->> code
       (core.str "(local core (require :nfnl.core))")
       fnl.eval
       core.println))

(fn plugin.run_selection_or_paragraph []
  "If in selection mode, run selection as fennel code, else run current paragraph"
  (var old-pos nil)
  (local is-visual-mode (: (vim.fn.mode) :match "[vV]"))
  (when (not is-visual-mode)
    (set old-pos (vim.api.nvim_win_get_cursor 0))
    (vim.cmd.normal :vip))
  (vim.cmd.normal (vim.api.nvim_replace_termcodes :<esc> true false true))
  (local code (text.get_selection_text))
  (when old-pos (vim.api.nvim_win_set_cursor 0 old-pos))
  (plugin.run_fnl code))

plugin
