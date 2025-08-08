(import-macros {: key! : cmd! : =>} :phenax.macros)
(local core (require :nfnl.core))
(local fnl (require :nfnl.fennel))

(local plugin {})

(fn run_fnl [code]
  (->> code
       (core.str "(local core (require :nfnl.core))")
       fnl.eval
       core.println))

(fn plugin.config []
  ;; Garbage collect file
  (key! :n :<c-n>d :<cmd>NfnlDeleteOrphans<cr>)
  ;; Execute current paragraph
  (key! :n :<c-n>x (fn [] (run_fnl "(print 'TODO: impl')")))
  (cmd! :Fnl (=> (. :args) run_fnl) {:nargs "*"}))

plugin
