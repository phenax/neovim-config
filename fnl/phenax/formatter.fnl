(import-macros {: key! : aucmd! : augroup!} :phenax.macros)
(local core (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))

(local formatter {:is_autoformat_enabled true})

(set formatter.lsp-alt-formatters
     {:eslint (fn [] (vim.cmd :EslintFixAll))
      :fennel_ls (fn [] (vim.cmd "sil !fnlfmt --fix %"))})

(set formatter.format-on-save-ft [:astro
                                  :c
                                  :cpp
                                  :crystal
                                  :elm
                                  :gleam
                                  :go
                                  :h
                                  :haskell
                                  :java
                                  :javascript
                                  :javascriptreact
                                  :lua
                                  :nix
                                  :purescript
                                  :racket
                                  :ruby
                                  :rust
                                  :scala
                                  :svelte
                                  :typescript
                                  :typescriptreact
                                  :uiua
                                  :unison
                                  :vue])

(fn formatter.initialize []
  (key! :n :<leader>df formatter.toggle-autoformat)
  (aucmd! :LspAttach
          {:group (augroup! :phenax/lspformatter {:clear true})
           :callback (fn []
                       (key! :n :<localleader>f formatter.format-buffer
                             {:silent true :buffer true}))})
  (formatter.setup-file-autoformat formatter.format-on-save-ft))

(fn formatter.setup-file-autoformat [fts]
  (lambda formatter.run-auto-formatter []
    (when formatter.is_autoformat_enabled
      (formatter.format-buffer)))
  (lambda setup_autoformat_for_ft [ev]
    (aucmd! :BufWritePre
            {:buffer ev.buf :callback formatter.run-auto-formatter}))
  (aucmd! :FileType {:callback setup_autoformat_for_ft :pattern fts}))

(fn formatter.toggle-autoformat []
  (set formatter.is_autoformat_enabled (not formatter.is_autoformat_enabled))
  (if formatter.is_autoformat_enabled
      (vim.notify "[Autoformat enabled]")
      (vim.notify "[Autoformat disabled]")))

(fn formatter.has-alt-formatter [client]
  (not_nil? (. formatter.lsp-alt-formatters client.name)))

(fn formatter.run-alt-formatter [client]
  (let [fmt (. formatter.lsp-alt-formatters client.name)] (fmt)))

(fn formatter.format-buffer []
  (local buf (vim.api.nvim_get_current_buf))
  (local clients (vim.lsp.get_clients {:bufnr buf}))
  (local clients_with_alt_fmt (core.filter formatter.has-alt-formatter clients))
  (if (core.empty? clients_with_alt_fmt)
      (vim.lsp.buf.format {:async false})
      (core.run! formatter.run-alt-formatter clients_with_alt_fmt)))

formatter
