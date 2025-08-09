(import-macros {: key!} :phenax.macros)
(local treesj (require :treesj))

(fn config []
  (key! :n :<leader>tt :<cmd>TSJToggle<cr>)
  (key! :n :<leader>ts :<cmd>TSJSplit<cr>)
  (key! :n :<leader>tj :<cmd>TSJJoin<cr>)
  (treesj.setup {:max_join_length 200 :use_default_keymaps false}))

{: config}
