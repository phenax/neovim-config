(macro init! [m]
  `((. (require ,m) :initialize)))

(local refactorings {})

(fn refactorings.initialize []
  (init! :phenax.refactorings.ruby)
  (init! :phenax.refactorings.js))

refactorings
