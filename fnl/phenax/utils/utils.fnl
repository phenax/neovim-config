(local {: empty?} (require :nfnl.core))

(local utils {})

(fn utils.present? [val]
  "Is the given value present / not empty?"
  (not (empty? val)))

utils
