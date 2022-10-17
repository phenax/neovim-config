local utils = require 'utils'
local nmap = utils.nmap

local editor = {}

function editor.plugins(use)
  use 'numToStr/Comment.nvim'
  use 'Townk/vim-autoclose'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'ggandor/leap.nvim'
  -- justinmk/vim-sneak

  use 'simrat39/symbols-outline.nvim'
  use 'lukas-reineke/indent-blankline.nvim'
  -- use 'ray-x/lsp_signature.nvim'
  -- use 'jubnzv/virtual-types.nvim'

  -- Syntax
  use 'sheerun/vim-polyglot' -- All syntax highlighting
  use 'norcalli/nvim-colorizer.lua' -- Hex/rgb colors

  -- Languages
  -- use 'rescript-lang/vim-rescript'
  -- use 'ashinkarov/nvim-agda'
  -- use 'dart-lang/dart-vim-plugin'
  -- use 'edwinb/idris2-vim'

  -- Folding
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    commit = '4cccb6f494eb255b32a290d37c35ca12584c74d0',
  }
  use 'nvim-treesitter/playground'
  use 'p00f/nvim-ts-rainbow'
  use 'nvim-treesitter/nvim-treesitter-textobjects'
  use 'nvim-treesitter/nvim-treesitter-context'
  use 'drybalka/tree-climber.nvim'
end

function editor.configure()
  g.context_enabled = 0

  g.rescript_bsb_exe = "bsb"
  g.rescript_bsc_exe = "bsc"
  g.rescript_legacy_mode = 1

  g.nvim_agda_settings = {
    agda = 'agda',
  }

  exec [[autocmd BufRead,BufEnter *.astro set filetype=astro]]

  -- Colorizer
  require'colorizer'.setup()
  g.indent_blankline_char = '┊'
  g.indent_blankline_space_char = ' '
  utils.updateScheme({
    'IndentBlanklineSpaceChar guifg=#1f1c29 gui=nocombine',
    'IndentBlanklineChar guifg=#1f1c29 gui=nocombine',
  })

  -- Treesitter
  require'nvim-treesitter.configs'.setup {
    ensure_installed = "all",
    highlight = { enable = true, },
    indent = { enable = true },
    textobjects = {
      enable = true,
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["aa"] = "@parameter.outer",
          ["ia"] = "@parameter.inner",
        },
        swap = {
          enable = true,
          swap_next = {
            ["<M-n>"] = "@parameter.inner",
          },
          swap_previous = {
            ["<M-p>"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["<leader>rn"] = "@function.outer",
          },
          goto_previous_start = {
            ["<leader>rp"] = "@function.outer",
          },
        },
        lsp_interop = {
          enable = true,
          border = 'none',
          peek_definition_code = {
            ["<leader>dt"] = "@function.outer",
          },
        },
      },
    },
  }

  -- Symbols
  nmap('<localleader>ns', ':SymbolsOutline<cr>')
  g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false,
    position = 'right',
    keymaps = {
      close = "q",
      goto_location = "<CR>",
      focus_location = "o",
      hover_symbol = "K",
      rename_symbol = "r",
      code_actions = "a",
    },
    lsp_blacklist = {},
  }

  require('Comment').setup({
    padding = true,
    toggler = {
        line = '<leader>cc',
        block = '<leader>bc',
    },
    opleader = {
      line = '<leader>c',
      block = '<leader>b',
    },
  })

  -- Open term in vim
  nmap('<localleader>tn', ':split term://node<cr>')
  nmap('<localleader>tt', ':split term://zsh<cr>')
  vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

  -- Sessions
  nmap('<leader>sw', ':mksession! .vim.session<cr>')
  nmap('<leader>sl', ':source .vim.session<cr>')

  -- Code navigation/searching
  --nmap('<localleader>cm', ':TagbarToggle<cr>')
  --exec [[map <localleader> <Plug>(easymotion-prefix)]] -- <space>c
  nmap('<c-\\>', ':noh<CR>')

  nmap('<localleader>rw', '*:%s//<c-r><c-w>')

  -- Folding
  nmap('<S-Tab>', 'zR')
  nmap('zx', 'zo')
  nmap('zc', 'zc')

  nmap('<C-n>', '10j')
  nmap('<C-m>', '10k')

  require'treesitter-context'.setup({
    enable = false,
    mode = 'cursor',
    separator = '―',
  })
  nmap('<leader>tc', ':TSContextToggle<CR>')

  local keyopts = { noremap = true, silent = true }
  vim.keymap.set({'n', 'v', 'o'}, 'H', require('tree-climber').goto_prev, keyopts)
  vim.keymap.set({'n', 'v', 'o'}, 'L', require('tree-climber').goto_next, keyopts)
  vim.keymap.set('n', '<c-h>', require('tree-climber').swap_prev, keyopts)
  vim.keymap.set('n', '<c-l>', require('tree-climber').swap_next, keyopts)

  -- Leap.nvim
  vim.keymap.set({'n', 'i', 'v'}, '<c-b>', function ()
    require('leap').leap { target_windows = { vim.fn.win_getid() } }
  end)
end

-- Bindings for tagbar
-- local function tagbarKeyBindings()
--   -- Scroll title to top
--   nmap('m', '<enter>zt<C-w><C-w>')
-- end

return editor

