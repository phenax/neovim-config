local utils = require 'utils'
local nmap = utils.nmap

local ide = {}

function ide.plugins(use)
  use 'scrooloose/nerdcommenter'
  use 'Townk/vim-autoclose'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  use 'easymotion/vim-easymotion'
  -- Hex colors
  use 'norcalli/nvim-colorizer.lua'

  -- Completions
  -- use 'Shougo/deoplete.nvim'

  -- Folding
  use 'wellle/context.vim'

  -- Search todo,fixme, etc comments
  use 'gilsondev/searchtasks.vim'
end

function ide.configure()
  g.searchtasks_list = {"TODO", "FIXME"} -- :SearchTasks
  -- g['deoplete#enable_at_startup'] = 1
  g.context_enabled = 0

  -- Open term in vim
  nmap('<localleader>tn', ':split term://node<cr>')
  nmap('<localleader>tt', ':split term://zsh<cr>')

  -- Sessions
  nmap('<leader>sw', ':mksession! .vim.session<cr>')
  nmap('<leader>sl', ':source .vim.session<cr>')

  -- Code navigation/searching
  nmap('<c-\\>', ':noh<CR>')
  exec [[map <localleader> <Plug>(easymotion-prefix)]] -- <space>c

  -- Folding
  nmap('<S-Tab>', 'zR')
  nmap('zx', 'zo')
  nmap('zc', 'zc')
  nmap('zf', ':ContextToggle<CR>')
end

function ide.init(use)
  ide.plugins(use)
  ide.configure()
end

return ide

