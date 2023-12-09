local M = {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-calc',
    'ray-x/cmp-treesitter',
    'onsails/lspkind-nvim',
  }
}

function M.config()
  local cmp = require 'cmp'
  cmp.setup {
    sources = {
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      -- { name = 'luasnip' },
      { name = 'path' },
      { name = 'buffer' },
      -- { name = 'neorg' },
      { name = 'calc' },
    },
    -- snippet = {
    --   expand = function(args)
    --     require('luasnip').lsp_expand(args.body)
    --   end,
    -- },
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

local function cmpDown(fallback)
  local cmp = require 'cmp'
  if cmp.visible() then
    cmp.select_next_item()
  -- elseif luasnip.expand_or_jumpable() then
  --   luasnip.expand_or_jump()
  else
    fallback()
  end
end

local function cmpUp(fallback)
  local cmp = require 'cmp'
  if cmp.visible() then
    cmp.select_prev_item()
  -- elseif luasnip.jumpable(-1) then
  --   luasnip.jump(-1)
  else
    fallback()
  end
end

return M
