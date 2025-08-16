(import-macros {: key! : cmd! : aucmd! : augroup! : bufcmd!} :phenax.macros)
(local {: not_empty?} (require :phenax.utils.utils))

(local plugin {})

(set plugin.lsp_servers (fn []
                          {:biome {}
                           :clangd {}
                           ; :crystalline {}
                           ; :denols {}
                           ; :elmls {:init_options {:elmReviewDiagnostics :warning}}
                           :eslint {}
                           :fennel_ls {}
                           ; :gleam {}
                           :gopls {}
                           :hls {:settings {:languageServerHaskell {:completionSnippetsOn true
                                                                    :hlintOn true}}}
                           ; :jdtls {},
                           :jsonls {:init_options {:provideFormatter true}}
                           :lua_ls (plugin.get-lua-ls-config)
                           ; :metals {} ; scala
                           :nixd {}
                           ; :ocamlls {},
                           ; :purescriptls {},
                           :racket_langserver {}
                           :rubocop {}
                           :rust_analyzer {:settings {:rust-analyzer {:cargo {:autoreload true}
                                                                      :checkOnSave true
                                                                      :diagnostics {:disabled [:unresolved-proc-macro]
                                                                                    :enable true}
                                                                      :procMacro {:enable true}}}}
                           ; :solargraph {:init_options {:formatting false}}
                           :ruby_lsp {:init_options {:formatter :auto
                                                     :initializationOptions {:enabledFeatures {:formatting false}}
                                                     :addonSettings {"Ruby LSP Rails" {:enablePendingMigrationsPrompt true}}}}
                           ; :svelte {},
                           :tailwindcss {}
                           :ts_ls (plugin.get-ts-ls-config)
                           :uiua {}
                           ; :unison {:settings {:maxCompletions 100}}
                           :yamlls {}}))

(fn plugin.config []
  (cmd! :LspInfoV "vert botright checkhealth vim.lsp" {})
  (aucmd! :LspAttach
          {:group (augroup! :phenax/lspattach {:clear true})
           :callback (fn [opts]
                       (plugin.on-lsp-attached opts.data.client_id opts.buf))})
  (plugin.configure-lsp-servers (plugin.lsp_servers))
  (plugin.configure-diagnostics))

(fn plugin.configure-lsp-servers [lsp_servers]
  "Setup the given lsp server configurations"
  (each [name options (pairs lsp_servers)]
    (when (not_empty? options)
      (vim.lsp.config name options)))
  (vim.lsp.enable (vim.tbl_keys lsp_servers)))

(fn plugin.configure-diagnostics []
  "Configure vim.diagnostic"
  (lambda virtual-text-prefix [diag]
    (if (= diag.severity vim.diagnostic.severity.ERROR) " "
        (= diag.severity vim.diagnostic.severity.WARN) " "
        "■ "))
  (vim.diagnostic.config {:float {:source true}
                          :severity_sort true
                          :signs true
                          :underline true
                          :virtual_text {:prefix virtual-text-prefix}}))

(fn plugin.on-lsp-attached [_client_id bufnr]
  ;; (local client (assert (vim.lsp.get_client_by_id client_id)))
  (local opts {:buffer bufnr :noremap true :silent true})
  (key! :n :K (fn [] (vim.lsp.buf.hover {:border :single})) opts)
  (key! :n :grn (fn [] (vim.lsp.buf.rename)) opts)
  ;; Diagnostics
  (key! :n :<localleader>e (fn [] (vim.diagnostic.open_float)) opts)
  (key! :n "[d" (fn [] (vim.diagnostic.goto_prev)) opts)
  (key! :n "]d" (fn [] (vim.diagnostic.goto_next)) opts)
  ;; Code action keys
  (key! :n :gra (fn [] (vim.lsp.buf.code_action)) opts)
  (key! :n :<leader>tu :<cmd>LspRemoveUnused<cr> opts)
  (key! :n :<leader>ta :<cmd>LspAddMissingImports<cr> opts))

(fn plugin.get-lua-ls-config []
  (local libraries
         {(vim.fn.expand :$VIMRUNTIME/lua) true
          (vim.fn.expand :$VIMRUNTIME/lua/vim/lsp) true})
  {:settings {:Lua {:diagnostics {:globals [:vim :web]}
                    :hint {:enable true}
                    :workspace {:library libraries
                                :maxPreload 100000
                                :preloadFileSize 10000}}}})

(fn plugin.get-ts-ls-config []
  (lambda add-missing-import []
    (vim.lsp.buf.code_action {:apply true
                              :context {:diagnostics {}
                                        :only [:source.addMissingImports.ts]}}))
  (lambda remove-unused-imports []
    (vim.lsp.buf.code_action {:apply true
                              :context {:diagnostics {}
                                        :only [:source.removeUnused.ts]}}))
  (local current_cfg vim.lsp.config.ts_ls)
  {:capabilities {:textDocument {:formatting false}}
   :on_attach (fn [client buf]
                (pcall current_cfg.on_attach client buf) ; Call lspconfigs on_attach
                (bufcmd! buf :LspAddMissingImports add-missing-import {})
                (bufcmd! buf :LspRemoveUnused remove-unused-imports {})
                (key! :n :<leader>ti :<cmd>LspTypescriptSourceAction<cr>
                      {:buffer buf}))
   :completions {:completeFunctionCalls true}})

plugin
