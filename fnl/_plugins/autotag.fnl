(local autotag (require :nvim-ts-autotag))

(fn opts []
  {:opts {:enable_close true :enable_close_on_slash true :enable_rename true}})

(fn config []
  (autotag.setup (opts)))

{: config}
