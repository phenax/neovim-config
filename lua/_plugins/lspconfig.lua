local plugin = {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- 'ray-x/lsp_signature.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
}

local function defaultCapabilities() return vim.lsp.protocol.make_client_capabilities() end

local function capDisableFormatting(cap)
  cap.textDocument.formatting = false
  return cap
end

local hoverOpt = { border = 'single' }
local handlers = {
  ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, hoverOpt),
  ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, hoverOpt),
}

local config = {
  is_autoformat_enabled = true,
  format_on_save_ft = {
    'astro',
    'c',
    'cpp',
    'crystal',
    'elm',
    'go',
    'h',
    'haskell',
    'java',
    'javascript',
    'javascriptreact',
    'lua',
    'nix',
    'purescript',
    'racket',
    'ruby',
    'rust',
    'scala',
    'svelte',
    'typescript',
    'typescriptreact',
    'uiua',
    'unison',
    'vue',
  },

  lsp_servers = function()
    local nvim_lsp = require 'lspconfig'
    return {
      jdtls = {},
      racket_langserver = {},
      uiua = {},
      zls = {},
      clangd = {},
      unison = { settings = { maxCompletions = 100 } },
      ocamlls = {},
      elmls = { init_options = { elmReviewDiagnostics = 'warning' } },
      asm_lsp = {},
      -- vuels = {
      --   settings = {
      --     vetur = {
      --       format = { enable = false },
      --       validation = {
      --         style = true,
      --         script = true,
      --         interpolation = true,
      --         template = true,
      --         templateProps = false,
      --       },
      --       completion = { autoImport = true, tagCasing = "kebab" },
      --     },
      --   },
      -- },
      -- purescriptls = {},
      -- metals = {}, -- scala
      -- gleam = {},
      -- crystalline = {},
      -- astro = {},
      svelte = {},

      rubocop = {},
      solargraph = {
        init_options = {
          formatting = false,
        },
      },
      yamlls = {},
      gopls = {},

      biome = {},
      eslint = {
        commands = {
          LspFormat = { function() vim.cmd [[ EslintFixAll ]] end },
        },
      },

      tailwindcss = {
        root_dir = nvim_lsp.util.root_pattern(
          'tailwind.config.js',
          'tailwind.config.cjs',
          'tailwind.config.mjs',
          'tailwind.config.ts'
        ),
        single_file_support = false,
      },

      -- denols = {},
      tsserver = {
        capabilities = capDisableFormatting(defaultCapabilities()),
        completions = {
          completeFunctionCalls = true,
        },
        init_options = {
          preferences = {
            -- Inlay hints
            interactiveInlayHints = true,
            importModuleSpecifierPreference = 'non-relative',
            includeInlayEnumMemberValueHints = true,
            includeInlayFunctionLikeReturnTypeHints = false,
            includeInlayFunctionParameterTypeHints = false,
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayVariableTypeHints = false, -- Disabled because it's noisy
          },
        },
        commands = {
          LspRemoveUnused = {
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = { only = { 'source.removeUnused.ts' }, diagnostics = {} },
              })
              -- vim.lsp.buf.code_action({ apply = true, context = { only = { 'source.organizeImports.ts' }, diagnostics = {} } })
            end,
          },
          LspAddMissingImports = {
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = { only = { 'source.addMissingImports.ts' }, diagnostics = {} },
              })
            end,
          },
        },
      },

      rust_analyzer = {
        settings = {
          ['rust-analyzer'] = {
            cargo = { autoreload = true, allFeatures = true },
            procMacro = { enable = true },
            checkOnSave = { command = 'clippy' },
            diagnostics = {
              enable = true,
              disabled = { 'unresolved-proc-macro' },
              enableExperimental = true,
            },
          },
        },
      },

      jsonls = {
        commands = {
          LspFormat = {
            function() vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line '$', 0 }) end,
          },
        },
      },

      nixd = {},

      hls = {
        -- filetypes = { 'haskell', 'lhaskell', 'liquid' },
        settings = {
          languageServerHaskell = { hlintOn = true, completionSnippetsOn = true },
        },
      },

      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            hint = {
              enable = true,
            },
            workspace = {
              library = {
                [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
                [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
              },
              maxPreload = 100000,
              preloadFileSize = 10000,
            },
          },
        },
      },
    }
  end,
}

-- Can be run to setup a language server dynamically
-- _SetupLspServer('name')
function _SetupLspServer(name, opts, autoformat_ft)
  local options = opts or {}
  local nvim_lsp = require 'lspconfig'
  local cap = options.capabilities or defaultCapabilities()
  cap = require('cmp_nvim_lsp').default_capabilities(cap)
  nvim_lsp[name].setup(vim.tbl_extend('force', {
    on_attach = config.on_lsp_attached,
    handlers = handlers,
    capabilities = cap,
  }, options))

  if autoformat_ft then config.setup_file_autoformat(autoformat_ft) end
end

function plugin.config()
  vim.g.markdown_fenced_languages = { "ts=typescript", "js=javascript" }

  -- Lsp
  for name, options in pairs(config.lsp_servers()) do
    _SetupLspServer(name, options)
  end

  -- Autoformatting
  vim.keymap.set('n', '<leader>df', config.toggle_autoformat)
  config.setup_file_autoformat(config.format_on_save_ft)

  -- diagnostics config
  vim.diagnostic.config {
    signs = true,
    underline = true,
    severity_sort = true,
    virtual_text = {
      prefix = function(diag)
        if diag.severity == vim.diagnostic.severity.ERROR then
          return ' '
        elseif diag.severity == vim.diagnostic.severity.WARN then
          return ' '
        end
        return '■ '
      end,
    },
    float = {
      source = true,
    },
  }
end

function config.on_lsp_attached(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  -- Navigation
  vim.keymap.set('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)

  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
  -- vim.keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', opts)
  -- vim.keymap.set('n', '<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

  vim.keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<cr>', opts)
  -- vim.keymap.set('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Refactor actions
  vim.keymap.set('n', '<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.keymap.set('n', '<localleader>aa', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.keymap.set('n', '<localleader>f', config.format_buffer, { silent = true, noremap = true })
  vim.keymap.set('n', '<leader>tu', '<cmd>LspRemoveUnused<cr>', opts) -- Remove unused imports

  -- Diagnostics
  vim.keymap.set('n', '<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  -- vim.keymap.set('n', '<localleader>d', '<cmd>Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', '<leader>xx', '<cmd>Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  -- Refresh code lenses
  -- if client.supports_method('textDocument/codeLens') then
  --   vim.lsp.codelens.refresh()
  --   vim.cmd [[autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]
  -- end

  if client.supports_method('textDocument/inlayHints') then
    local filter = { bufnr = bufnr }
    vim.lsp.inlay_hint.enable(false, filter)
    vim.keymap.set('n', '<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), {})
    end, opts)
  end

  -- Show function signature as a popup
  -- require('lsp_signature').on_attach({
  --   bind = true,
  --   hi_parameter = 'LspSignatureActiveParameter',
  -- }, bufnr)
end

function config.setup_file_autoformat(fts)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    callback = function(ev)
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        callback = config.run_auto_formatter,
      })
    end,
  })
end

-- Autoformatting hooks
function config.toggle_autoformat()
  config.is_autoformat_enabled = not config.is_autoformat_enabled
  if config.is_autoformat_enabled then
    vim.notify '[Autoformat enabled]'
  else
    vim.notify '[Autoformat disabled]'
  end
end

function config.run_auto_formatter()
  if config.is_autoformat_enabled then config.format_buffer() end
end

function config.format_buffer()
  if vim.fn.exists ':LspFormat' > 0 then
    vim.cmd [[sil LspFormat]]
  else
    vim.cmd [[sil lua vim.lsp.buf.format({ async = false })]]
  end
end

return plugin
