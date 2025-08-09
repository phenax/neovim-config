(import-macros {: key! : aucmd!} :phenax.macros)
(local {: not_nil?} (require :phenax.utils.utils))

(local folding {:group nil :max-level 20 :min-level 1})

(fn folding.initialize []
  (set folding.group (vim.api.nvim_create_augroup :phenax/folding {:clear true}))
  (folding.configure)
  (folding.setup_force_reevaluation)
  (folding.setup_lsp_folding))

(fn folding.configure []
  (set vim.opt.foldmethod :expr)
  (set vim.opt.foldexpr "nvim_treesitter#foldexpr()")
  (set vim.opt.foldlevel 50)
  (set vim.opt.foldenable false)
  (set vim.opt.foldtext "")
  (set vim.opt.foldcolumn :0)
  (vim.opt.fillchars:append {:fold "-"})
  (key! :n :<S-Tab> :zR)
  (key! :n :<leader><Tab> (fn [] (folding.toggle_foldlevel)) {:silent true}))

(fn folding.toggle_foldlevel []
  (if (>= vim.o.foldlevel folding.max-level)
      (do
        (vim.cmd "normal! zM<CR>")
        (set vim.o.foldlevel folding.min-level))
      (do
        (vim.cmd "normal! zR<CR>")
        (set vim.o.foldlevel folding.max-level))))

(fn folding.setup_force_reevaluation []
  (aucmd! :FileType
          {:group folding.group
           :callback (fn []
                       (local fold_expr
                              (if (= vim.o.filetype :org)
                                  "nvim_treesitter#foldexpr()"
                                  vim.opt_local.foldexpr))
                       (set vim.opt_local.foldexpr fold_expr)
                       (set vim.opt_local.foldlevel 50)
                       (set vim.opt_local.foldenable false))}))

(fn folding.setup_lsp_folding []
  (aucmd! :LspAttach
          {:group folding.group
           :callback (fn [args]
                       (local client
                              (vim.lsp.get_client_by_id args.data.client_id))
                       (when (and (not_nil? client)
                                  (client:supports_method :textDocument/foldingRange))
                         (local win_id (vim.api.nvim_get_current_win))
                         (tset (. vim.wo win_id 0) :foldexpr
                               "v:lua.vim.lsp.foldexpr()")
                         (tset (. vim.wo win_id 0) :foldmethod :expr)))}))

folding
