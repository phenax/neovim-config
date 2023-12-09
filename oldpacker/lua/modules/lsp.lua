local utils = require 'utils'
local nvim_lsp = require 'lspconfig'
local nmap = utils.nmap
local nmap_options = utils.nmap_options

local function defaultCapabilities()
  local cap = vim.lsp.protocol.make_client_capabilities()
  return cap
end

local function capDisableFormatting(cap)
  cap.textDocument.formatting = false
  return cap
end

local lsp = {
  lsp_format_on_save = {
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
    "ruby",
    "astro",
    "unison",
    "scala",
    "crystal",
    "c",
    "h",
    "cpp",
    "uiua",
    "go",
    "racket"
  },

  lsp_servers = {
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
    ruby_ls = {},
    yamlls = {},
    gopls = {},

    eslint = {
      commands = {
        LspFormat = { function() vim.cmd [[ EslintFixAll ]]; end },
      }
    },

    tailwindcss = {
      root_dir = nvim_lsp.util.root_pattern('tailwind.config.js', 'tailwind.config.cjs', 'tailwind.config.mjs', 'tailwind.config.ts'),
      single_file_support = false,
    },

    tsserver = {
      capabilities = capDisableFormatting(defaultCapabilities()),
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

    rnix = {},

    hls = {
      settings = {
        languageServerHaskell = { hlintOn = true, completionSnippetsOn = true },
      },
    },
  },
}

function lsp.plugins(use)
  use 'neovim/nvim-lspconfig'
  use 'ray-x/lsp_signature.nvim'
  use 'jubnzv/virtual-types.nvim'
  -- use 'glepnir/lspsaga.nvim'

  -- completion
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-calc',
      'ray-x/cmp-treesitter',
      'onsails/lspkind-nvim',
    }
  }

  -- snippets
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use 'rafamadriz/friendly-snippets'

  -- use 'tjdevries/nlua.nvim'

  use {
    'folke/trouble.nvim',
    requires = 'nvim-tree/nvim-web-devicons',
  }
end

function lsp.format_buffer()
  if vim.fn.exists(':LspFormat') > 0 then
    vim.cmd [[LspFormat]]
  else
    vim.lsp.buf.format({ async = false })
  end
end

function lsp.on_lsp_attached(client, bufnr)
  local opts = { noremap=true, silent=true }

  -- Navigation
  nmap_options('K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)

  nmap_options('gr', '<cmd>Telescope lsp_references<cr>', opts)
  nmap_options('<leader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

  nmap_options('gd', '<cmd>Telescope lsp_definitions<cr>', opts)
  nmap_options('<leader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)

  nmap_options('gt', '<cmd>Telescope lsp_type_definitions<cr>', opts)
  nmap_options('<leader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

  -- Refactor actions
  nmap_options('<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  nmap_options('<localleader>aa', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  -- nmap_options('<localleader>f', "<cmd>lua vim.lsp.buf.format({ async = true })<CR>", opts)
  vim.keymap.set('n', '<localleader>f', lsp.format_buffer, { silent = true, noremap = true })

  -- Diagnostics
  nmap_options('<localleader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
  nmap_options('<localleader>d', '<cmd>Telescope diagnostics<cr>', opts)
  nmap_options('[d', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
  nmap_options(']d', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)

  require('trouble').setup {
    mode = 'workspace_diagnostics',
    position = 'bottom',
    height = 16,
  }
  nmap('<leader>xx', ':TroubleToggle workspace_diagnostics<cr>')

  -- Refresh code lenses
  if client.server_capabilities.codeLensProvider ~= nil then
    vim.lsp.codelens.refresh()
    exec [[ autocmd InsertLeave <buffer> lua vim.lsp.codelens.refresh() ]]

    -- Show types as virtual text
    require'virtualtypes'.on_attach(client, bufnr)
  end

  -- Show function signature
  local config = {
    bind = true,
    hi_parameter = 'LspSignatureActiveParameter',
  }
  require 'lsp_signature'.on_attach(config, bufnr)
end

function lsp.configure()
  -- Lsp
  local capabilities = vim.lsp.protocol.make_client_capabilities()

  local nvim_lsp = require 'lspconfig'
  for name, options in pairs(lsp.lsp_servers) do
    local cap = options.capabilities or capabilities
    cap = require('cmp_nvim_lsp').default_capabilities(cap)

    nvim_lsp[name].setup(utils.merge({ on_attach = lsp.on_lsp_attached, capabilities = cap }, options))
  end

  -- lua
  -- require('nlua.lsp.nvim').setup(nvim_lsp, {
  --   on_attach = lsp.on_lsp_attached,
  -- })

  -- Autoformatting
  nmap("<leader>df", ":lua lsp___toggle_autoformat()<CR>")
  exec("autocmd FileType "
    ..table.concat(lsp.lsp_format_on_save, ",")
    .." autocmd  BufWritePre <buffer> silent! :lua lsp___on_save()")

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

  -- LSP saga
  -- require 'lspsaga'.init_lsp_saga()

  -- Completions
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'

  require("luasnip.loaders.from_vscode").load()

  local cmpDown = function(fallback)
    if cmp.visible() then
      cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      fallback()
    end
  end
  local cmpUp = function(fallback)
    if cmp.visible() then
      cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      fallback()
    end
  end

  cmp.setup {
    sources = {
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
      { name = 'neorg' },
      { name = 'calc' },
    },
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = {
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      },
      ['<down>'] = cmpDown,
      ['<up>'] = cmpUp,
      ['<C-j>'] = cmpDown,
      ['<C-k>'] = cmpUp,
    },
  }
end

-- function check_capability(feature)
--   local clients = vim.lsp.get_active_clients()
--
--   for _, client in pairs(clients) do
--     if client.resolved_capabilities[feature] then
--       return true
--     end
--   end
--
--   return false
-- end

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
    lsp.format_buffer()
  end
end

return lsp

