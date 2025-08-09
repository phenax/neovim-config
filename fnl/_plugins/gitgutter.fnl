(import-macros {: key!} :phenax.macros)

(fn config []
  (key! :n :<localleader>hh "<Plug>(GitGutterPreviewHunk)")
  (key! :n :<localleader>hn "<Plug>(GitGutterNextHunk)")
  (key! :n :<localleader>hp "<Plug>(GitGutterPrevHunk)")
  (key! :n :<localleader>hs "<Plug>(GitGutterStageHunk)")
  (key! :n :<localleader>hu "<Plug>(GitGutterUndoHunk)"))

{: config}
