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
    'L3MON4D3/LuaSnip',
  },
}

local function cmpDown(fallback)
  local cmp = require 'cmp'
  local luasnip = require 'luasnip'
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
  local luasnip = require 'luasnip'
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
        luasnip.lsp_expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert(mappings),
    confirm_opts = {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
  }

  cmp.setup.filetype('norg', {
    sources = cmp.config.sources({
      { name = 'neorg' },
    })
  })

  -- cmp.setup.cmdline(':', {
  --   mapping = vim.tbl_extend('force', cmp.mapping.preset.cmdline(), mappings),
  --   sources = cmp.config.sources(
  --     { { name = 'path' } },
  --     { { name = 'cmdline', option = { ignore_cmds = { 'Man', '!' } } } }
  --   )
  -- })
  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = { { name = 'buffer' } },
  })
end

return plugin
