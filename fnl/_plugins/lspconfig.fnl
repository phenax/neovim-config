(import-macros {: key! : cmd! : aucmd!} :phenax.macros)
(local lspconfig (require :lspconfig))
(local core (require :nfnl.core))
(local {: not_nil?} (require :phenax.utils.utils))
(local blink (require :blink.cmp))

(local plugin {})

(fn cap-disable-formatting [cap] (set cap.textDocument.formatting false) cap)

(local config {:is_autoformat_enabled true})

(set config.alt_formatters
     {:eslint (fn [] (vim.cmd :EslintFixAll))
      :fennel_ls (fn [] (vim.cmd "sil !fnlfmt --fix %"))})

(set config.format_on_save_ft [:astro
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

(set config.lsp_servers (fn []
                          {:biome {}
                           :clangd {}
                           ; crystalline = {},
                           ; denols = {},
                           ; :elmls {:init_options {:elmReviewDiagnostics :warning}}
                           :eslint {}
                           :fennel_ls {}
                           ; :gleam {}
                           :gopls {}
                           :hls (config.get-hls-config)
                           ; jdtls = {},
                           :jsonls {:init_options {:provideFormatter true}}
                           :lua_ls (config.get-lua-ls-config)
                           ; metals = {}, -- scala
                           :nixd {}
                           ; ocamlls = {},
                           ; purescriptls = {},
                           :racket_langserver {}
                           :rubocop {}
                           :rust_analyzer {:settings {:rust-analyzer {:cargo {:autoreload true}
                                                                      :checkOnSave true
                                                                      :diagnostics {:disabled [:unresolved-proc-macro]
                                                                                    :enable true}
                                                                      :procMacro {:enable true}}}}
                           :solargraph {:init_options {:formatting false}}
                           ; svelte = {},
                           :tailwindcss {}
                           :ts_ls (config.get-ts-ls-config)
                           ; :uiua {}
                           ; :unison {:settings {:maxCompletions 100}}
                           :yamlls {}}))

(fn plugin.config []
  (key! :n :<leader>df config.toggle_autoformat)
  (cmd! :LspInfoV "vert botright checkhealth vim.lsp" {})
  (each [name options (pairs (config.lsp_servers))]
    (_G._SetupLspServer name options))
  (config.setup_file_autoformat config.format_on_save_ft)

  (fn virtual_text_prefix [diag]
    (if (= diag.severity vim.diagnostic.severity.ERROR) " "
        (= diag.severity vim.diagnostic.severity.WARN) " "
        "■ "))

  (vim.diagnostic.config {:float {:source true}
                          :severity_sort true
                          :signs true
                          :underline true
                          :virtual_text {:prefix virtual_text_prefix}}))

(fn config.on_lsp_attached [client bufnr]
  (local opts {:buffer bufnr :noremap true :silent true})
  (key! :n :K (fn [] (vim.lsp.buf.hover {:border :single})) opts)
  (key! :n :grn (fn [] (vim.lsp.buf.rename)) opts)
  (key! :n :<localleader>f config.format_buffer {:noremap true :silent true})
  ;; Diagnostics
  (key! :n :<localleader>e (fn [] (vim.diagnostic.open_float)) opts)
  (key! :n "[d" (fn [] (vim.diagnostic.goto_prev)) opts)
  (key! :n "]d" (fn [] (vim.diagnostic.goto_next)) opts)
  ;; Code action keys
  (key! :n :gra (fn [] (vim.lsp.buf.code_action)) opts)
  (key! :n :<leader>tu :<cmd>LspRemoveUnused<cr> opts)
  (key! :n :<leader>ta :<cmd>LspAddMissingImports<cr> opts)
  ;; Inlay hints
  (when (client:supports_method :textDocument/inlayHints)
    (local filter {: bufnr})
    (vim.lsp.inlay_hint.enable false filter)

    (fn toggle-inlay-hint []
      (vim.lsp.inlay_hint.enable (not (vim.lsp.inlay_hint.is_enabled filter))
                                 {}))

    (key! :n :<C-t>h toggle-inlay-hint opts)))

; (fn config.get-fennel-ls-config []
;   (local def (nfnl-config.default {:root-dir "." :rtp-patterns ["."]}))
;   {:settings {:fennel-ls {:extra-globals "vim Snacks"
;                           :fennel-path def.fennel-path
;                           :libraries {:nvim true}
;                           :lua-version :lua5.1
;                           :macro-path def.fennel-macro-path}}})

(fn config.get-lua-ls-config []
  {:settings {:Lua {:diagnostics {:globals [:vim :web]}
                    :hint {:enable true}
                    :workspace {:library {(vim.fn.expand :$VIMRUNTIME/lua) true
                                          (vim.fn.expand :$VIMRUNTIME/lua/vim/lsp) true
                                          (.. (vim.fn.stdpath :data)
                                               :/lazy/lazy.nvim/lua/lazy) true}
                                :maxPreload 100000
                                :preloadFileSize 10000}}}})

(fn config.get-hls-config []
  (fn remove-unused-imports []
    (vim.lsp.buf.code_action {:apply true
                              :context {:diagnostics {} :only [:quickfix]}
                              :filter (fn [cmd]
                                        (= cmd.title
                                           "Remove all redundant imports"))}))

  {:commands {:LspRemoveUnused [remove-unused-imports]}
   :settings {:languageServerHaskell {:completionSnippetsOn true :hlintOn true}}})

(fn config.get-ts-ls-config []
  (fn add-missing-import []
    (vim.lsp.buf.code_action {:apply true
                              :context {:diagnostics {}
                                        :only [:source.addMissingImports.ts]}}))

  (fn remove-unused-imports []
    (vim.lsp.buf.code_action {:apply true
                              :context {:diagnostics {}
                                        :only [:source.removeUnused.ts]}}))

  {:capabilities (cap-disable-formatting (vim.lsp.protocol.make_client_capabilities))
   :commands {:LspAddMissingImports [add-missing-import]
              :LspRemoveUnused [remove-unused-imports]}
   :completions {:completeFunctionCalls true}})

;; Can be run to setup a language server dynamically
;; _SetupLspServer('name')
(fn _G._SetupLspServer [name opts]
  (local options (or opts {}))
  (var cap
       (or options.capabilities (vim.lsp.protocol.make_client_capabilities)))
  (set cap (blink.get_lsp_capabilities cap))
  (local lspclient (. lspconfig name))
  (lspclient:setup (vim.tbl_extend :force
                                   {:capabilities cap
                                    :on_attach config.on_lsp_attached}
                                   options)))

(fn config.setup_file_autoformat [fts]
  (lambda config.run_auto_formatter []
    (when config.is_autoformat_enabled
      (config.format_buffer)))
  (lambda setup_autoformat_for_ft [ev]
    (aucmd! :BufWritePre {:buffer ev.buf :callback config.run_auto_formatter}))
  (aucmd! :FileType {:callback setup_autoformat_for_ft :pattern fts}))

(fn config.toggle_autoformat []
  (set config.is_autoformat_enabled (not config.is_autoformat_enabled))
  (if config.is_autoformat_enabled
      (vim.notify "[Autoformat enabled]")
      (vim.notify "[Autoformat disabled]")))

(fn config.has_alt_formatter [client]
  (not_nil? (. config.alt_formatters client.name)))

(fn config.run_alt_formatter [client]
  (let [fmt (. config.alt_formatters client.name)] (fmt)))

(fn config.format_buffer []
  (local buf (vim.api.nvim_get_current_buf))
  (local clients (vim.lsp.get_clients {:bufnr buf}))
  (local clients_with_alt_fmt (core.filter config.has_alt_formatter clients))
  (if (core.empty? clients_with_alt_fmt)
      (vim.lsp.buf.format {:async false})
      (core.run! config.run_alt_formatter clients_with_alt_fmt)))

plugin
