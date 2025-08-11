(macro init! [m]
  `((. (require ,m) :initialize)))

(init! :phenax.localconfig)
(init! :phenax.repl)
(init! :phenax.rulerline)
(init! :phenax.folding)
(init! :phenax.search)
(init! :phenax.quickfix)
(init! :phenax.sortable_buffers)
(init! :phenax.refactorings.init)
(init! :phenax.typescript)
(init! :phenax.snacks_picker_history)
(init! :phenax.colorizer)
