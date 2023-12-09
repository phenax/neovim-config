local plugin = {
  'hrsh7th/nvim-cmp',
  event = 'BufRead',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-calc',
    'ray-x/cmp-treesitter',
    'onsails/lspkind-nvim',
    'hrsh7th/cmp-cmdline',

    {
      'L3MON4D3/LuaSnip',
      version = "v2.*",
      build = "make install_jsregexp",
      dependencies = {
        'saadparwaiz1/cmp_luasnip',
        'rafamadriz/friendly-snippets',
      },
    },
  },
}

local function cmpDown(fallback)
  local cmp = require 'cmp'
  if cmp.visible() then
    cmp.select_next_item()
  elseif luasnip.expand_or_jumpable() then
    luasnip.expand_or_jump()
  else
    fallback()
  end
end

local function cmpUp(fallback)
  local cmp = require 'cmp'
  if cmp.visible() then
    cmp.select_prev_item()
  elseif luasnip.jumpable(-1) then
    luasnip.jump(-1)
  else
    fallback()
  end
end

function plugin.config()
  local cmp = require 'cmp'

  -- LuaSnip
  require("luasnip").filetype_extend("all", { "_" })
  require("luasnip.loaders.from_vscode").lazy_load()

  local mappings = {
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm {},
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<down>'] = cmp.mapping(cmpDown),
    ['<up>'] = cmp.mapping(cmpUp),
    ['<C-j>'] = cmp.mapping(cmpDown),
    ['<C-k>'] = cmp.mapping(cmpUp),
  }

  cmp.setup {
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
      { name = 'calc' },
    }),
    snippet = {
      expand = function(args)
        require('luasnip').lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert(mappings),
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    experimental = {
      ghost_text = true,
    },
  }

  cmp.setup.filetype('norg', {
    sources = cmp.config.sources({
      { name = 'neorg' },
    })
  })

  -- cmp.setup.cmdline(":", {
  --   mapping = cmp.mapping.preset.cmdline(),
  --   sources = {
  --     { name = "cmdline" },
  --   },
  -- })
end

return plugin
