local blink_plugin = {
  'saghen/blink.cmp',
  version = '1.*',
}

local plugin = {
  blink_plugin,
  { 'rafamadriz/friendly-snippets', event = 'InsertEnter' },
}

function blink_plugin.config()
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
      ghost_text = { enabled = false },
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' },
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      per_filetype = {
        org = { 'orgmode', 'path', 'snippets', 'buffer' },
      },
      providers = {
        lsp = {
          score_offset = 20,
          fallbacks = {},
        },
        path = {
          score_offset = 15,
        },
        snippets = {
          score_offset = 10,
          max_items = 5,
        },
        buffer = {
          score_offset = -5,
          max_items = 5,
          opts = {
            get_bufnrs = function()
              return vim.tbl_filter(function(bufnr)
                return vim.bo[bufnr].buftype == ''
              end, vim.api.nvim_list_bufs())
            end,
          },
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
