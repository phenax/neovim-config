(import-macros {: cmd!} :phenax.macros)
(fn gh [p] (.. "https://github.com/" p))
(local version vim.version.range)

(vim.pack.add [{:src (gh :nvim-lua/plenary.nvim)}
               {:src (gh :nvim-treesitter/nvim-treesitter)}
               {:src (gh :github/copilot.vim)}
               {:src (gh :olimorris/codecompanion.nvim)}
               {:src (gh :folke/snacks.nvim)}
               {:src (gh :tpope/vim-fugitive)}
               {:src (gh :airblade/vim-gitgutter)}
               {:src (gh :neovim/nvim-lspconfig)}
               {:src (gh :echasnovski/mini.surround)}
               {:src (gh :stevearc/oil.nvim)}
               {:src (gh :nvim-orgmode/orgmode)}
               {:src (gh :rafamadriz/friendly-snippets)}
               {:src (gh :nvim-treesitter/nvim-treesitter-textobjects)}
               {:src (gh :Wansmer/treesj)}
               {:src (gh :aaronik/treewalker.nvim)}
               {:src (gh :Olical/nfnl)}
               {:src (gh :saghen/blink.cmp) :version (version :1.*)}
               {:src (gh :windwp/nvim-ts-autotag)}])

(cmd! :PackUpdate (fn [] (vim.pack.update)) {})
