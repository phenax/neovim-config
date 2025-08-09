(macro init! [m]
  `((. (require ,m) :initialize)))

(local refactorings {})

(fn refactorings.initialize []
  (print (require :phenax.refactorings.ruby))
  (print (require :phenax.refactorings.js))
  (init! :phenax.refactorings.ruby)
  (init! :phenax.refactorings.js))

refactorings
