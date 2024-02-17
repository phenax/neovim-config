local plugin = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'ray-x/lsp_signature.nvim',
    'jubnzv/virtual-types.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },
}

local function defaultCapabilities()
  return vim.lsp.protocol.make_client_capabilities()
end

local function capDisableFormatting(cap)
  cap.textDocument.formatting = false
  return cap
end

local config = {
  is_autoformat_enabled = true,

  format_on_save_ft = {
    'haskell',
    'purescript',
    'nix',
    'rust',
    'elm',
    'vue',
    'svelte',
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
    'ruby',
    'astro',
    'unison',
    'scala',
    'crystal',
    'c',
    'h',
    'cpp',
    'uiua',
    'go',
    'racket',
    -- 'lua',
  },

  lsp_servers = function()
    local nvim_lsp = require 'lspconfig'
    return {
      racket_langserver = {},
      uiua = {},
      zls = {},
      clangd = {},
      unison = {
        settings = {
          maxCompletions = 100,
        },
      },
      ocamlls = {},
      elmls = { init_options = { elmReviewDiagnostics = 'warning' } },
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
      -- svelte = {},

      rubocop = {},
      solargraph = {
        init_options = {
          formatting = false,
        },
      },
      -- ruby_ls = {
      --   init_options = {
      --     formatter = false,
      --   },
      -- },
      yamlls = {},
      gopls = {},

      eslint = {
        commands = {
          LspFormat = { function() vim.cmd [[ EslintFixAll ]]; end },
        }
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

      tsserver = {
        capabilities = capDisableFormatting(defaultCapabilities()),
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
            function()
              vim.lsp.buf.range_formatting({}, { 0, 0 }, { vim.fn.line('$'), 0 })
            end
          }
        }
      },

      rnix = {},

      hls = {
        settings = {
          languageServerHaskell = { hlintOn = true, completionSnippetsOn = true },
        },
      },

      lua_ls = {
        on_init = function(client)
          local path = client.workspace_folders[1].name
          if not vim.loop.fs_stat(path .. '/.luarc.json') and not vim.loop.fs_stat(path .. '/.luarc.jsonc') then
            client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
              Lua = {
                runtime = { version = 'LuaJIT' },
                workspace = {
                  checkThirdParty = false,
                  library = { vim.env.VIMRUNTIME },
                },
              },
            })
            client.notify('workspace/didChangeConfiguration', { settings = client.config.settings })
          end
          return true
        end,
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
  nvim_lsp[name].setup(vim.tbl_extend('force', { on_attach = config.on_lsp_attached, capabilities = cap }, options))

  if autoformat_ft then
    config.setup_file_autoformat(autoformat_ft)
  end
end

function plugin.config()
  -- Lsp
  for name, options in pairs(config.lsp_servers()) do
    _SetupLspServer(name, options)
  end

  -- Autoformatting
  vim.keymap.set('n', '<leader>df', config.toggle_autoformat)
  config.setup_file_autoformat(config.format_on_save_ft)

  -- diagnostics config
  vim.diagnostic.config({
    signs = true,
    underline = true,
    severity_sort = true,
    virtual_text = {
      prefix = '■',
    },
    float = {
      source = 'always',
    },
  })
end

function config.on_lsp_attached(client, bufnr)
  local opts = { noremap = true, silent = true }

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

  -- Diagnostics
  vim.keymap.set('n', '<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  -- vim.keymap.set('n', '<localleader>d', '<cmd>Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', '<leader>xx', '<cmd>Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  -- Refresh code lenses
  if client.server_capabilities.codeLensProvider ~= nil then
    vim.lsp.codelens.refresh()
    vim.cmd [[autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh()]]

    -- Show types as virtual text
    require 'virtualtypes'.on_attach(client, bufnr)
  end

  -- Show function signature
  require 'lsp_signature'.on_attach({
    bind = true,
    hi_parameter = 'LspSignatureActiveParameter',
  }, bufnr)
end

function config.setup_file_autoformat(fts)
  vim.api.nvim_create_autocmd('FileType', {
    pattern = fts,
    callback = function(ev)
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        callback = config.run_auto_formatter
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
  if config.is_autoformat_enabled then
    config.format_buffer()
  end
end

function config.format_buffer()
  if vim.fn.exists(':LspFormat') > 0 then
    vim.cmd [[sil LspFormat]]
  else
    vim.cmd [[sil lua vim.lsp.buf.format({ async = false })]]
  end
end

return plugin
