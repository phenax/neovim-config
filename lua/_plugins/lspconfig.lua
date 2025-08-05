local plugin = {
  'neovim/nvim-lspconfig',
  dependencies = {
    'saghen/blink.cmp',
  },
}

local function default_capabilities()
  return vim.lsp.protocol.make_client_capabilities()
end

local function cap_disable_formatting(cap)
  cap.textDocument.formatting = false
  return cap
end

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
    'gleam',
  },

  alt_formatters = {
    eslint = function() vim.cmd 'EslintFixAll' end,
    -- biome = function()
    --   local bufnr = vim.api.nvim_get_current_buf()
    --   local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'biome' })
    --   if #clients == 0 then return end
    --   local params = vim.lsp.util.make_formatting_params()
    --   local response = clients[1]:request_sync('textDocument/formatting', params, bufnr)
    --   if not response or not response.result then return end
    --   vim.lsp.util.apply_text_edits(response.result, bufnr, clients[1].offset_encoding)
    -- end,
  },

  lsp_servers = function()
    local nvim_lsp = require 'lspconfig'
    return {
      racket_langserver = {},
      uiua = {},
      clangd = {},
      unison = { settings = { maxCompletions = 100 } },
      elmls = { init_options = { elmReviewDiagnostics = 'warning' } },
      gleam = {},
      -- jdtls = {},
      -- zls = {},
      -- ocamlls = {},
      -- asm_lsp = {},
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
      -- crystalline = {},
      -- astro = {},
      -- svelte = {},

      rubocop = {},
      solargraph = {
        init_options = {
          formatting = false,
        },
      },
      yamlls = {},
      gopls = {},

      biome = {},
      eslint = {},

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
      ts_ls = {
        capabilities = cap_disable_formatting(default_capabilities()),
        completions = {
          completeFunctionCalls = true,
        },
        commands = {
          LspRemoveUnused = {
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = { only = { 'source.removeUnused.ts' }, diagnostics = {} },
              })
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
            cargo = { autoreload = true },
            procMacro = { enable = true },
            checkOnSave = true,
            diagnostics = {
              enable = true,
              disabled = { 'unresolved-proc-macro' },
            },
          },
        },
      },

      jsonls = {
        init_options = { provideFormatter = true },
      },

      nixd = {},

      hls = {
        -- filetypes = { 'haskell', 'lhaskell', 'liquid' },
        settings = {
          languageServerHaskell = { hlintOn = true, completionSnippetsOn = true },
        },
        commands = {
          LspRemoveUnused = {
            function()
              vim.lsp.buf.code_action({
                apply = true,
                context = { only = { 'quickfix' }, diagnostics = {} },
                filter = function(cmd) return cmd.title == 'Remove all redundant imports' end,
              })
            end,
          },
        },
      },

      lua_ls = {
        settings = {
          Lua = {
            diagnostics = {
              globals = { 'vim', 'web' },
            },
            hint = {
              enable = true,
            },
            workspace = {
              library = {
                [vim.fn.expand('$VIMRUNTIME/lua')] = true,
                [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
                [vim.fn.stdpath('data') .. '/lazy/lazy.nvim/lua/lazy'] = true,
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
  local cap = options.capabilities or default_capabilities()
  cap = require('blink.cmp').get_lsp_capabilities(cap)
  nvim_lsp[name].setup(vim.tbl_extend('force', {
    on_attach = config.on_lsp_attached,
    capabilities = cap,
  }, options))

  if autoformat_ft then config.setup_file_autoformat(autoformat_ft) end
end

function plugin.config()
  vim.g.markdown_fenced_languages = { 'ts=typescript', 'js=javascript' }

  -- Lsp
  for name, options in pairs(config.lsp_servers()) do
    _SetupLspServer(name, options)
  end

  -- Autoformatting
  vim.keymap.set('n', '<leader>df', config.toggle_autoformat)
  config.setup_file_autoformat(config.format_on_save_ft)

  vim.api.nvim_create_user_command('LspInfoV', 'vert botright checkhealth vim.lsp', {});

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
  vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover({ border = "single" })<cr>', opts)

  -- Moved to snacks picker
  -- vim.keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  -- vim.keymap.set('n', '<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  -- vim.keymap.set('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Refactor actions
  vim.keymap.set('n', 'grn', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
  vim.keymap.set('n', 'gra', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
  vim.keymap.set('n', '<localleader>f', config.format_buffer, { silent = true, noremap = true })
  vim.keymap.set('n', '<leader>tu', '<cmd>LspRemoveUnused<cr>', opts)      -- Remove unused imports
  vim.keymap.set('n', '<leader>ta', '<cmd>LspAddMissingImports<cr>', opts) -- Add missing imports

  -- Diagnostics
  vim.keymap.set('n', '<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  -- Toggle inlay hints
  if client.supports_method('textDocument/inlayHints') then
    local filter = { bufnr = bufnr }
    vim.lsp.inlay_hint.enable(false, filter)
    vim.keymap.set('n', '<C-t>h', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), {})
    end, opts)
  end
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
  if not config.is_autoformat_enabled then return end

  config.format_buffer()
end

function config.has_alt_formatter(client)
  return config.alt_formatters[client.name]
end

function config.format_buffer()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = buf })
  if #clients == 0 then return end

  local is_formatted = false
  for _, client in ipairs(clients) do
    if config.has_alt_formatter(client) then
      config.alt_formatters[client.name]()
      is_formatted = true
    end
  end

  if not is_formatted then
    vim.lsp.buf.format({ async = false })
  end
end

return plugin
