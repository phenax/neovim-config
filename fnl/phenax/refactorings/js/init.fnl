(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local js_testing (require :phenax.refactorings.js.testing))
(local js_core (require :phenax.refactorings.js.core))
(local js_async (require :phenax.refactorings.js.async))

(local js {})

(fn js.initialize []
  (aucmd! :FileType
          {:pattern [:javascript :typescript :javascriptreact :typescriptreact]
           :callback (fn [] (js.setup_current_buf))}))

(fn js.setup_current_buf []
  (key! :ia :await (fn [] (pcall js_async.wrap_async_around_closest_function) :await)
        {:buffer true :expr true})
  (key! :v :<leader>rll js_core.add_log_for_selected_text {:buffer true})
  (key! :v :<leader>rev js_core.extract_selected_text_as_value {:buffer true})
  (key! :n :<leader>rit js_testing.toggle_it {:buffer true}))

js
