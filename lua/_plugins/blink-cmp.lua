local plugin = {
  'saghen/blink.cmp',
  version = '1.*',
  dependencies = {
    'rafamadriz/friendly-snippets',
    'fang2hou/blink-copilot',
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
      documentation = { auto_show = true },
      ghost_text = { enabled = false },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer', 'copilot' },
      per_filetype = {
        org = { 'orgmode', 'path', 'snippets', 'buffer', 'copilot' },
      },
      providers = {
        lsp = { score_offset = 20 },
        snippets = { score_offset = 15 },
        path = { score_offset = 10 },
        buffer = { score_offset = 0 },
        copilot = {
          name = 'Copilot',
          module = 'blink-copilot',
          enabled = function() return vim.g.copilot_enabled end,
          score_offset = 16,
          async = true,
          transform_items = function(_, items)
            for _, item in ipairs(items) do
              item.kind_hl = '@phenax.pmenukind.copilot'
            end
            return items
          end,
        },
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
