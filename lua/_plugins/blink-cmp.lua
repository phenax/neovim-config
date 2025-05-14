local plugin = {
  'saghen/blink.cmp',
  version = '1.*',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'fang2hou/blink-copilot',
    'github/copilot.vim',
  },
}

function plugin.config()
  require 'blink.cmp'.setup {
    keymap = {
      preset = 'default',
      ['<CR>'] = { 'accept', 'fallback' },
      ['<C-y>'] = { 'select_and_accept' },
      ['<Tab>'] = { 'snippet_forward', 'fallback' },
      ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
      ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
    },
    completion = {
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 80,
      },
      ghost_text = {
        enabled = false,
      },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      per_filetype = {
        org = { 'orgmode', 'path', 'snippets', 'buffer', 'copilot' },
      },
      providers = {
        lsp = { score_offset = 20, fallbacks = { 'buffer' } },
        snippets = { score_offset = 10 },
        path = { score_offset = 5 },
        copilot = {
          score_offset = 15,
          name = 'Copilot',
          module = 'blink-copilot',
          enabled = function() return vim.g.copilot_enabled end,
          async = true,
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.kind_hl = '@phenax.pmenukind.copilot'
            end
            return items
          end,
        },
        buffer = { score_offset = -5 },
        orgmode = {
          name = 'Orgmode',
          module = 'orgmode.org.autocompletion.blink',
          score_offset = 20,
        },
      },
    },
  }
end

return plugin
