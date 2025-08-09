(import-macros {: key! : aucmd! : ?call} :phenax.macros)
(local ruby_core (require :phenax.refactorings.ruby.core))
(local ruby_memery (require :phenax.refactorings.ruby.memery))

(local ruby {})

(fn ruby.initialize []
  (aucmd! :FileType {:callback (fn [] (ruby.setup_current_buf))
                     :pattern [:ruby]}))

(fn ruby.setup_current_buf []
  (key! :ia :memoize (fn [] (pcall ruby_memery.include_memery_around_class) :memoize)
        {:buffer true :expr true})
  (key! :v :<leader>rev ruby_core.extract_selected_text_as_method
        {:buffer true}))

ruby
