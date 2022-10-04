local utils = require 'utils'
local nmap = utils.nmap
local nmap_options = utils.nmap_options

local editor = {}

function editor.plugins(use)
  use 'numToStr/Comment.nvim'
  use 'Townk/vim-autoclose'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
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
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate', commit = '5dfbbcc' }
  use 'nvim-treesitter/playground'
  use 'p00f/nvim-ts-rainbow'
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
    ensure_installed = "all", -- "all" | "maintained" | list of languages
    highlight = { enable = true, },
    indent = { enable = true },
    textobjects = { enable = true },
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
end

-- local function refactor(prompt_bufnr)
--   local content = require("telescope.actions.state").get_selected_entry(prompt_bufnr)
--   require("telescope.actions").close(prompt_bufnr)
--   require("refactoring").refactor(content.value)
-- end
-- 
-- Refactor = {}
-- Refactor.refactors = function()
--   local opts = require("telescope.themes").get_cursor() -- set personal telescope options
--   require("telescope.pickers").new(opts, {
--     prompt_title = "refactors",
--     finder = require("telescope.finders").new_table({
--       results = require("refactoring").get_refactors(),
--     }),
--     sorter = require("telescope.config").values.generic_sorter(opts),
--     attach_mappings = function(_, map)
--       map("i", "<CR>", refactor)
--       map("n", "<CR>", refactor)
--       return true
--     end
--   }):find()
-- end

-- Bindings for tagbar
function tagbarKeyBindings()
  -- Scroll title to top
  nmap('m', '<enter>zt<C-w><C-w>')
end

return editor

