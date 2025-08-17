(import-macros {: key! : aucmd! : augroup!} :phenax.macros)
(local core (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))

(local formatter {:autoformat? true})

(set formatter.lsp-alt-formatters {:eslint (fn [] (vim.cmd :EslintFixAll))})

(set formatter.ft-alt-formatters
     {:fennel (fn []
                (formatter.fmt-buffer (fn [] (vim.cmd "sil %!fnlfmt -"))))
      :json (fn []
              (formatter.fmt-buffer (fn [] (vim.cmd "sil %!jq"))))})

(set formatter.format-on-save-ft [:astro
                                  :c
                                  :cpp
                                  :crystal
                                  :elm
                                  :gleam
                                  :go
                                  :haskell
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
  (lambda run-auto-formatter [ev]
    (local ft (vim.api.nvim_get_option_value :filetype {:buf ev.buf}))
    (local can-autoformat? (vim.tbl_contains fts ft))
    (when (and can-autoformat? formatter.autoformat?)
      (formatter.format-buffer)))
  (aucmd! :BufWritePre {:callback run-auto-formatter}))

(fn formatter.fmt-buffer [func]
  (local cur (vim.api.nvim_win_get_cursor 0))
  (func)
  (vim.api.nvim_win_set_cursor 0 cur))

(fn formatter.toggle-autoformat []
  (set formatter.autoformat? (not formatter.autoformat?))
  (if formatter.autoformat?
      (vim.notify "[Autoformat enabled]")
      (vim.notify "[Autoformat disabled]")))

(fn formatter.get-alt-formatter [buf]
  (lambda has-lsp-fmt [client]
    (not_nil? (. formatter.lsp-alt-formatters client.name)))
  (local ft (vim.api.nvim_get_option_value :filetype {: buf}))
  (local clients (vim.lsp.get_clients {:bufnr buf}))
  (local client (core.first (core.filter has-lsp-fmt clients)))
  (local ft-formatter (. formatter.ft-alt-formatters ft))
  (if (not_nil? client) (. formatter.lsp-alt-formatters client.name)
      (not_nil? ft-formatter) ft-formatter
      nil))

(fn formatter.format-buffer []
  (local buf (vim.api.nvim_get_current_buf))
  (local alt-formatter (formatter.get-alt-formatter buf))
  (if (core.function? alt-formatter)
      (alt-formatter)
      (vim.lsp.buf.format {:async false})))

formatter
