local nvim_lsp = require 'lspconfig'

local function defaultCapabilities()
  return vim.lsp.protocol.make_client_capabilities()
end

local function capDisableFormatting(cap)
  cap.textDocument.formatting = false
  return cap
end

local M = {
  is_autoformat_enabled = true,

  format_on_save_ft = {
    "haskell",
    "purescript",
    "nix",
    "rust",
    "elm",
    "vue",
    "svelte",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "astro",
    "unison",
    "scala",
    "crystal",
    "c",
    "h",
    "cpp"
  },

  lsp_servers = {
    eslint = {
      commands = {
        LspFormat = { function() vim.cmd [[ EslintFixAll ]]; end },
      }
    },

    clangd = {},

    unison = {
      settings = {
        maxCompletions = 100,
      },
    },

    tailwindcss = {
      root_dir = nvim_lsp.util.root_pattern('tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts'),
      single_file_support = false,
    },

    -- scala
    metals = {},

    -- gleam = {},
    -- crystalline = {},

    tsserver = {
      capabilities = capDisableFormatting(defaultCapabilities()),
    },

    astro = {},
    svelte = {},

    vuels = {
      settings = {
        vetur = {
          format = { enable = false },
          validation = {
            style = true,
            script = true,
            interpolation = true,
            template = true,
            templateProps = false,
          },
          completion = { autoImport = true, tagCasing = "kebab" },
        },
      },
    },

    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          cargo = { autoreload = true, allFeatures = true },
          procMacro = { enable = true },
          checkOnSave = { command = "clippy" },
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
        LspFormat = {
          function()
            vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
          end
        }
      }
    },

    elmls = { init_options = { elmReviewDiagnostics = 'warning' } },

    rnix = {},

    ocamlls = {},

    hls = {
      settings = {
        languageServerHaskell = { hlintOn = true, completionSnippetsOn = true },
      },
    },

    purescriptls = {},
  },
}

function M.setup()
  -- Lsp
  local nvim_lsp = require 'lspconfig'
  for name, options in pairs(M.lsp_servers) do
    local cap = options.capabilities or defaultCapabilities()
    cap = require('cmp_nvim_lsp').default_capabilities(cap)

    nvim_lsp[name].setup(vim.tbl_extend("force", { on_attach = M.on_lsp_attached, capabilities = cap }, options))
  end

  -- Autoformatting
  vim.keymap.set('n', '<leader>df', M.toggle_autoformat)
  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = M.format_on_save_ft,
    callback = function(ev)
      vim.api.nvim_create_autocmd({ "BufWritePre" }, { buffer = ev.buf, callback = M.run_auto_formatter })
    end,
  })

  -- diagnostics config
  vim.diagnostic.config({
    signs = true,
    underline = true,
    severity_sort = true,
    virtual_text = {
      prefix = '■',
    },
    float = {
      source = "always",
    },
  })
end

function M.on_lsp_attached(client, bufnr)
  local opts = { noremap=true, silent=true }

  -- Navigation
  vim.keymap.set('n', 'K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)

  vim.keymap.set('n', 'gr', '<cmd>Telescope lsp_references<cr>', opts)
  vim.keymap.set('n', '<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  vim.keymap.set('n', 'gd', '<cmd>Telescope lsp_definitions<cr>', opts)
  vim.keymap.set('n', '<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

  vim.keymap.set('n', 'gt', '<cmd>Telescope lsp_type_definitions<cr>', opts)
  vim.keymap.set('n', '<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Refactor actions
  vim.keymap.set('n', '<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  vim.keymap.set('n', '<localleader>aa', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.keymap.set('n', '<localleader>f', M.format_buffer, { silent = true, noremap = true })

  -- Diagnostics
  vim.keymap.set('n', '<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  vim.keymap.set('n', '<localleader>d', '<cmd>Telescope diagnostics<cr>', opts)
  vim.keymap.set('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  vim.keymap.set('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  -- Refresh code lenses
  if client.server_capabilities.codeLensProvider ~= nil then
    vim.lsp.codelens.refresh()
    exec [[ autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh() ]]

    -- Show types as virtual text
    require'virtualtypes'.on_attach(client, bufnr)
  end

  -- Show function signature
  require 'lsp_signature'.on_attach({
    bind = true,
    hi_parameter = 'LspSignatureActiveParameter',
  }, bufnr)
end

-- Autoformatting hooks
function M.toggle_autoformat()
  M.is_autoformat_enabled = not M.is_autoformat_enabled
  if M.is_autoformat_enabled then
    print "[Autoformat enabled]"
  else
    print "[Autoformat disabled]"
  end
end

function M.run_auto_formatter()
  if M.is_autoformat_enabled then
    M.format_buffer()
  end
end

function M.format_buffer()
  if vim.fn.exists(':LspFormat') > 0 then
    vim.cmd [[LspFormat]]
  else
    vim.lsp.buf.format({ async = false })
  end
end

return M
