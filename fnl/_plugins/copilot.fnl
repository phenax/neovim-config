(import-macros {: key!} :phenax.macros)
(local m {})

(fn config []
  (set vim.g.copilot_enabled false)
  (key! :n :<leader>sm (fn [] (m.toggle_copilot))))

(fn m.toggle_copilot []
  (if vim.g.copilot_enabled
      (do
        (vim.cmd "Copilot disable")
        (print "Copilot disabled")
        (set vim.g.copilot_enabled false))
      (do
        (vim.cmd "Copilot enable")
        (print "Copilot enabled")
        (set vim.g.copilot_enabled true))))

{: config}
