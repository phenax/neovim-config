(import-macros {: key!} :phenax.macros)
(local codecompanion (require :codecompanion))

(fn config []
  (key! [:n :x] :<a-c>c "<cmd>CodeCompanionChat Toggle<cr>")
  (key! [:n :x] :<a-c>a "<cmd>CodeCompanionChat Add<cr>")
  (key! [:n :x] :<a-c>e "<cmd>CodeCompanion /explain<cr>")
  (key! [:n :x] :<a-c>p :<cmd>CodeCompanionActions<cr>)
  ;; ga: accept diff
  ;; gr: reject diff
  (codecompanion.setup {:prompt_library (require :phenax.codecompanion-prompts)
                        :strategies {:agent {:adapter :copilot}
                                     :chat {:adapter :copilot
                                            :opts {:completion_provider :blink}}
                                     :inline {:adapter :copilot}}}))

{: config}
