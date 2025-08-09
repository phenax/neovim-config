(local {: empty? : nil? : merge} (require :nfnl.core))

(local utils { :++ merge })

(fn utils.present? [val]
  "Is the given value present / not empty?"
  ;; TODO: Make this work for values of any type
  (not (empty? val)))

(fn utils.not_nil? [val]
  (not (nil? val)))

(fn utils.clamp [n min max] (math.min (math.max n min) (or max math.huge)))

(fn utils.index-of [item ls]
  (each [_index x (ipairs ls)]
    (when (= item x)
      (lua "return _index")))
  nil)

utils
