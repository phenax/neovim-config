(import-macros {: key! : cmd!} :phenax.macros)
(local lspconfig (require :lspconfig))
(local blink (require :blink.cmp))
(local nfnl-config (require :nfnl.config))

(local plugin {})

(fn cap-disable-formatting [cap] (set cap.textDocument.formatting false) cap)

(local config {:is_autoformat_enabled true})

(set config.alt_formatters
     {:eslint (fn [] (vim.cmd :EslintFixAll))
      :fennel_ls (fn [] (vim.cmd "!fnlfmt --fix %"))})

(set config.format_on_save_ft [:astro
                               :c
                               :cpp
                               :crystal
                               :elm
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
                               :vue
                               :gleam])

(set config.lsp_servers (fn []
                          {:biome {}
                           :clangd {}
                           ; crystalline = {},
                           ; denols = {},
                           ; :elmls {:init_options {:elmReviewDiagnostics :warning}}
                           :eslint {}
                           :fennel_ls (config.get-fennel-ls-config)
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
                           :tailwindcss {:root_dir (lspconfig.util.root_pattern :tailwind.config.js
                                                                                :tailwind.config.cjs
                                                                                :tailwind.config.mjs
                                                                                :tailwind.config.ts)
                                         :single_file_support false}
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
    (if (= diag.severity vim.diagnostic.severity.ERROR) (lua "return \" \"")
        (= diag.severity vim.diagnostic.severity.WARN) (lua "return \" \""))
    "■ ")

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

(fn config.get-fennel-ls-config []
  (local def (nfnl-config.default {:root-dir "." :rtp-patterns ["."]}))
  {:settings {:fennel-ls {:extra-globals "vim Snacks"
                          :fennel-path def.fennel-path
                          :libraries {:nvim true}
                          :lua-version :lua5.1
                          :macro-path def.fennel-macro-path}}})

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
(fn _G._SetupLspServer [name opts autoformat-ft]
  (local options (or opts {}))
  (local nvim_lsp (require :lspconfig))
  (var cap
       (or options.capabilities (vim.lsp.protocol.make_client_capabilities)))
  (set cap (blink.get_lsp_capabilities cap))
  ((. nvim_lsp name :setup) (vim.tbl_extend :force
                                            {:capabilities cap
                                             :on_attach config.on_lsp_attached}
                                            options))
  (when autoformat-ft (config.setup_file_autoformat autoformat-ft)))

(fn config.setup_file_autoformat [fts]
  (vim.api.nvim_create_autocmd :FileType
                               {:callback (fn [ev]
                                            (vim.api.nvim_create_autocmd :BufWritePre
                                                                         {:buffer ev.buf
                                                                          :callback config.run_auto_formatter}))
                                :pattern fts}))

(fn config.toggle_autoformat []
  (set config.is_autoformat_enabled (not config.is_autoformat_enabled))
  (if config.is_autoformat_enabled (vim.notify "[Autoformat enabled]")
      (vim.notify "[Autoformat disabled]")))

(fn config.run_auto_formatter []
  (when (not config.is_autoformat_enabled) (lua "return "))
  (config.format_buffer))

(fn config.has_alt_formatter [client] (. config.alt_formatters client.name))

(fn config.format_buffer []
  (let [buf (vim.api.nvim_get_current_buf)
        clients (vim.lsp.get_clients {:bufnr buf})]
    (when (= (length clients) 0) (lua "return "))
    (var is-formatted false)
    (each [_ client (ipairs clients)]
      (when (config.has_alt_formatter client)
        ((. config.alt_formatters client.name))
        (set is-formatted true)))
    (when (not is-formatted) (vim.lsp.buf.format {:async false}))))

plugin
