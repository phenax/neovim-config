local utils = require 'utils'
local nmap = utils.nmap

local git = {}

function git.plugins(use)
  use 'tpope/vim-fugitive'
  -- use { 'TimUntersberger/neogit', requires = 'nvim-lua/plenary.nvim' }

  use 'rhysd/git-messenger.vim'
  -- use 'rbong/vim-flog'

  use 'airblade/vim-gitgutter'
  -- Alt use 'lewis6991/gitsigns.nvim'

  use {
    'ruifm/gitlinker.nvim',
    requires = 'nvim-lua/plenary.nvim',
  }
end

function git.configure()
  g.gitgutter_max_signs = 500

  -- Permalink generation
  require("gitlinker").setup() -- \gy (copy permalink)

  -- Preview hunk inline
  nmap('<localleader>hh', '<Plug>(GitGutterPreviewHunk)')

  -- Git next/prev hunk
  nmap('<localleader>hn', '<Plug>(GitGutterNextHunk)')
  nmap('<localleader>hp', '<Plug>(GitGutterPrevHunk)')

  -- Stage/undo hunk
  nmap('<localleader>hs', '<Plug>(GitGutterStageHunk)')
  nmap('<localleader>hu', '<Plug>(GitGutterUndoHunk)')

  -- Diffresult merge in left/right
  nmap('<localleader>gl', ':diffget //2<cr>')
  nmap('<localleader>gr', ':diffget //3<cr>')

  -- Git status/log
  nmap('<localleader>gs', ':G<cr>')
  nmap('<localleader>gll', ':Commits<cr>')
  nmap('<localleader>glf', ':BCommits<cr>')
  nmap('<localleader>gm', ':GitMessenger<cr>')
  nmap('<localleader>gbb', ':Telescope git_branches<cr>')

  -- Add
  nmap('<localleader>ga.', ':Git add .<cr>')
  nmap('<localleader>gaf', ':Git add %<cr>')

  -- Add/Commit/Push/Pull
  nmap('<localleader>gcc', ':Git commit<cr>')
  nmap('<localleader>gca', ':Git commit --amend<cr>')
  nmap('<localleader>gpp', ':Git push<cr>')
  nmap('<localleader>gpu', ':Git pull<cr>')
end

return git
