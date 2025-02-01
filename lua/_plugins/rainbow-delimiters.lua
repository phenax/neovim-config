vim.g.rainbow_delimiters = {
  highlight = {
    'RainbowDelimiter1',
    'RainbowDelimiter2',
    'RainbowDelimiter3',
    'RainbowDelimiter4',
    'RainbowDelimiter5',
    'RainbowDelimiter6',
  },
  whitelist = {
    'racket',
    'scheme',
    'lisp',
  },
}

return {
  'HiPhish/rainbow-delimiters.nvim',
  event = 'BufReadPost',
}
