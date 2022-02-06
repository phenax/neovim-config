local utils = require 'utils'
local nmap = utils.nmap
local nmap_options = utils.nmap_options

function capabilityDisableFormatting()
  local cap = vim.lsp.protocol.make_client_capabilities()
  cap.textDocument.formatting = false
  return cap
end

-- local eslint = {
--   lintCommand = "eslint_d -f visualstudio --stdin --stdin-filename ${INPUT}", -- -f unix
--   lintStdin = true,
--   --lintFormats = {"%f:%l:%c: %m"},
--   lintFormats = {"%f(%l,%c): %tarning %m", "%f(%l,%c): %rror %m"},
--   lintIgnoreExitCode = true,
-- 
--   formatCommand = "eslint_d --fix-to-stdout --stdin --stdin-filename=${INPUT}",
--   formatStdin = true,
-- 
--   --hoverCommand = ""
--   --hoverStdin = true,
-- }

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
    -- efm = {
    --   filetypes = {
    --     "javascript",
    --     "typescript",
    --     "javascriptreact",
    --     "typescriptreact",
    --     "vue",
    --   },
    --   init_options = {
    --     documentFormatting = true,
    --     hover = true,
    --     documentSymbol = true,
    --     codeAction = true,
    --   },
    --   settings = {
    --     rootMarkers = {".eslintrc.js", ".eslintrc.json"},
    --     languages = {
    --       typescript = { eslint },
    --       javascript = { eslint },
    --       vue = { eslint },
    --     },
    --   },
    -- },

    eslint = {},

    tsserver = {
      capabilities = capabilityDisableFormatting(),
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
            template = true,
            templateProps = true,
          },
          completion = {
            autoImport = true,
            tagCasing = "kebab",
          },
          experimental = {
            templateInterpolationService = true,
          },
        },
      },
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

    elmls = {
      init_options = {
        elmReviewDiagnostics = 'warning',
      },
    },

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

  -- completion
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'ray-x/cmp-treesitter'

  -- snippets
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'
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
  nmap_options('<localleader>d', '<cmd>lua vim.diagnostic.set_loclist()<CR>', opts)
  nmap_options('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  nmap_options(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
  nmap_options('<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
end

-- function lsp__code_action_listener()
--   local context = { diagnostics = vim.lsp.diagnostic.get_line_diagnostics() }
--   local params = lsp_util.make_range_params()
--   params.context = context
--   vim.lsp.buf_request(0, 'textDocument/codeAction', params, function(err, _, result)
--     -- do something with result - e.g. check if empty and show some indication such as a sign
--   end)
-- end

function lsp.configure()
  -- Lsp
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local nvim_lsp = require 'lspconfig'
  for name, options in pairs(lsp.lsp_servers) do
    local cap = options.capabilities or capabilities
    cap = require('cmp_nvim_lsp').update_capabilities(cap)

    nvim_lsp[name].setup(utils.merge({ on_attach = lsp.on_lsp_attached, capabilities = cap }, options))
  end

  -- Autoformatting
  nmap("<leader>df", ":lua lsp___toggle_autoformat()<CR>")
  exec("autocmd FileType "
    ..table.concat(lsp.lsp_format_on_save, ",")
    .." autocmd  BufWritePre <buffer> silent! :lua lsp___on_save()")

  -- LSP saga
  -- require 'lspsaga'.init_lsp_saga()

  -- Completions
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  require("luasnip.loaders.from_vscode").load()

  cmp.setup {
    sources = {
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      { name = 'luasnip' },
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-e>'] = cmp.mapping.close(),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end,
      ['<S-Tab>'] = function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end,
    }
  }

  -- exec [[ autocmd CursorHold,CursorHoldI * lua lsp__code_action_listener() ]]
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

return lsp

