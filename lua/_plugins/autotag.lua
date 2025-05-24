return {
  'windwp/nvim-ts-autotag',
  event = 'BufReadPost',
  opts = {
    opts = {
      enable_close = true,
      enable_rename = true,
      enable_close_on_slash = true,
    },
  },
}
