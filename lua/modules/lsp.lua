local utils = require 'utils'
local nmap = utils.nmap
local nmap_options = utils.nmap_options

function disableFormatting()
  local cap = vim.lsp.protocol.make_client_capabilities()
  cap.textDocument.formatting = false
  return cap
end

local eslint = {
  lintCommand = "eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}", -- -f unix
  lintStdin = true,
  --lintFormats = {"%f:%l:%c: %m"},
  lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
  lintIgnoreExitCode = true,

  formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
  formatStdin = true,

  --hoverCommand = ""
  --hoverStdin = true,
}

local lsp = {
  lsp_format_on_save = {
    "haskell",
    "nix",
    "rust",
    "elm",
    "vue",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },

  lsp_servers = {
    efm = {
      filetypes = {
        "javascript",
        "typescript",
        "javascriptreact",
        "typescriptreact",
        "vue",
      },
      init_options = {
        documentFormatting = true,
        hover = true,
        documentSymbol = true,
        codeAction = true,
      },
      settings = {
        rootMarkers = {".eslintrc.js", ".eslintrc.json"},
        languages = {
          typescript = { eslint },
          javascript = { eslint },
          vue = { eslint },
        },
      },
    },
    vuels = {
      settings = {
        vetur = {
          format = {
            enable = false,
          },
          validation = {
            style = true,
            script = true,
            interpolation = true,
          },
          completion = {
            autoImport = true,
          },
        },
      },
    },
    tsserver = {
      capabilities = disableFormatting(),
    },

    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = {
            autoreload = true,
            allFeatures = true,
          },
          procMacro = {
            enable = true,
          },
          checkOnSave = {
            command = "clippy",
          },
          diagnostics = {
            enable = true,
            disabled = {"unresolved-proc-macro"},
            enableExperimental = true,
          },
        },
      },
    },

    jsonls = {
      commands = {
        Format = {
          function()
            vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
          end
        }
      }
    },

    elmls = {},
    rnix = {},
    ocamlls = {},
    hls = {
      settings = {
        languageServerHaskell = {
          hlintOn = true,
        },
      },
    },
  },
}

function lsp.plugins(use)
  use 'neovim/nvim-lspconfig'
  use 'glepnir/lspsaga.nvim'
  use 'nvim-lua/completion-nvim'
  use 'nvim-treesitter/completion-treesitter'
end

function lsp.on_lsp_attached(client, bufnr)
  local opts = { noremap=true, silent=true }

  -- Navigation
  nmap_options('<localleader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  nmap_options('<localleader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  nmap_options('<localleader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  nmap_options('K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)
  --nmap_options('K', ':Lspsaga hover_doc<CR>', opts)

  -- Refactor actions
  nmap_options('<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  nmap_options('<localleader>aa', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  nmap_options('<localleader>f', "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

  -- Diagnostics
  nmap_options('<localleader>d', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  nmap_options('[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  nmap_options(']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  nmap_options('<localleader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
end

-- Autoformatting hooks
is_autoformat_enabled = true;
function lsp___toggle_autoformat()
  is_autoformat_enabled = not is_autoformat_enabled
  if is_autoformat_enabled then
    print "[Autoformat enabled]"
  else
    print "[Autoformat disabled]"
  end
end
function lsp___on_save()
  if is_autoformat_enabled then
    vim.lsp.buf.formatting_seq_sync(nil, 300)
  end
end

function lsp.configure()
  -- Lsp
  local nvim_lsp = require 'lspconfig'
  for name, options in pairs(lsp.lsp_servers) do
    nvim_lsp[name].setup(utils.merge({ on_attach = lsp.on_lsp_attached }, options))
  end

  -- Autoformatting
  nmap("<leader>df", ":lua lsp___toggle_autoformat()<CR>")
  exec("autocmd FileType "
    ..table.concat(lsp.lsp_format_on_save, ",")
    .." autocmd  BufWritePre <buffer> silent! :lua lsp___on_save()")

  -- LSP saga
  require 'lspsaga'.init_lsp_saga()


  -- Completions
  exec [[autocmd BufEnter * lua require'completion'.on_attach()]]
  utils.set('completeopt', 'menuone,noinsert,noselect')
  g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
  g.completion_matching_smart_case = 1
  exec [[
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  ]]
end

return lsp

