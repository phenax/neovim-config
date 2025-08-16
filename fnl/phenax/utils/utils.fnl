(local {: empty? : nil? : merge} (require :nfnl.core))
(local str (require :nfnl.string))

(local utils {:++ merge})

(fn utils.not_empty? [val]
  "Is the given value not empty?"
  (not (empty? val)))

(fn utils.present? [val]
  "Is the given value present?"
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

(fn utils.split_lines [input] (str.split input "\n"))

(fn utils.join_lines [input] (table.concat input "\n"))

(fn utils.slice_list [ls min ?max]
  "vim.list_slice but support negative values for min"
  (if (and (nil? ?max) (< min 0))
      (vim.list_slice ls (+ min (length ls)))
      (vim.list_slice ls min ?max)))

utils
