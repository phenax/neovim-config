return {
  '3rd/image.nvim',
  ft = { 'org', 'markdown' },
  enabled = false,
  config = function()
    require 'image'.setup {
      backend = 'kitty',
      processor = 'magick_cli',
      integrations = {
        markdown = { enabled = true },
        norg = { enabled = false },
      },
    }
  end,
}
