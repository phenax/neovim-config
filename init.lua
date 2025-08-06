require '_settings'
require '_settings.theme'.setup 'default'

local version = vim.version.range

---@format disable-next
vim.pack.add {
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
  { src = 'https://github.com/windwp/nvim-ts-autotag' },
  { src = 'https://github.com/github/copilot.vim' },
  { src = 'https://github.com/olimorris/codecompanion.nvim' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/tpope/vim-fugitive' },
  { src = 'https://github.com/airblade/vim-gitgutter' },
  { src = 'https://github.com/neovim/nvim-lspconfig' },
  { src = 'https://github.com/echasnovski/mini.surround' },
  { src = 'https://github.com/stevearc/oil.nvim' },
  { src = 'https://github.com/nvim-orgmode/orgmode' },
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-textobjects' },
  { src = 'https://github.com/Wansmer/treesj' },
  { src = 'https://github.com/aaronik/treewalker.nvim' },
  { src = 'https://github.com/sheerun/vim-polyglot' },
  { src = 'https://github.com/saghen/blink.cmp', version = version('1.*') },
}

require 'phenax'
require 'phenax.packer'.load '_plugins'
