(import-macros {: key!} :phenax.macros)
(local treewalker (require :treewalker))

(fn config []
  (key! [:n :v] :<Down> "<cmd>Treewalker Down<cr>" {:noremap true})
  (key! [:n :v] :<Up> "<cmd>Treewalker Up<cr>" {:noremap true})
  (key! [:n :v] :<Left> "<cmd>Treewalker Left<cr>" {:noremap true})
  (key! [:n :v] :<Right> "<cmd>Treewalker Right<cr>" {:noremap true})
  (key! :n :<C-Down> "<cmd>Treewalker SwapDown<cr>" {:noremap true})
  (key! :n :<C-Up> "<cmd>Treewalker SwapUp<cr>" {:noremap true})
  (treewalker.setup {:highlight true}))

{: config}
