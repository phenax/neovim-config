return {
  'vhyrro/luarocks.nvim',
  priority = 1000,
  config = true,
  opts = {
    -- luarocks_build_args = {
    --   'CURL_DIR=' .. vim.env.CURL_DIR,
    -- },
    rocks = {
      -- 'lua-curl', -- .. vim.env.CURL_DIR .. '/libcurl.so',
      'nvim-nio',
      'mimetypes',
      'xml2lua',
      'lua-utils.nvim',
      'nui.nvim',
      'plenary.nvim',
      'pathlib.nvim',
    },
  }
}
