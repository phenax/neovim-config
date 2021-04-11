local utils = require 'utils'
local nmap = utils.nmap
local nmap_silent = utils.nmap_silent

local fs = {}

function fs.plugins(use)
  use 'junegunn/fzf'
  use 'junegunn/fzf.vim'
  use 'djoshea/vim-autoread'
  use {
    'nvim-telescope/telescope.nvim',
    requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
  }
end

function fs.configure()
  -- File tree
  nmap_silent('<localleader>nn', ':CocCommand explorer<cr>')

  require('telescope').setup {
    defaults = {
      prompt_position = "top",
      prompt_prefix = "λ ",
      sorting_strategy = "ascending",
      width = 0.3,
      preview_cutoff = 120,
      color_devicons = true,
      use_less = true,
    }
  }

  -- Fuzzy file finder
  if utils.fexists('.git') then
    nmap_silent('<leader>f', ':Telescope git_files<cr>')
  else
    nmap_silent('<leader>f', ':Telescope find_files<cr>')
  end

  -- Global content search
  nmap_silent('<c-f>', ':Telescope live_grep<cr>')
  nmap_silent('<leader>mm', ':Telescope marks<cr>')

  -- Tag navigation
  nmap_silent('<c-c>', ':Telescope tags<cr>')

  -- Set buffer file type
  nmap_silent('<leader>cf', ':Telescope filetypes<cr>')

  exec [[autocmd StdinReadPre * let s:std_in=1autocmd StdinReadPre * let s:std_in=1]]
  exec [[autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exec 'bd' | endif]]
  
  exec [[autocmd BufEnter * if (winnr("$") == 1 && &filetype == 'coc-explorer') | q | endif]]
  exec [[autocmd FileType coc-explorer setlocal nolist]]
end

return fs
