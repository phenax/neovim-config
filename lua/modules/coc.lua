local utils = require 'utils'
local nmap = utils.nmap

local coc = {}

function coc.plugins(use)
  use 'ludovicchabant/vim-gutentags'
  use { 'neoclide/coc.nvim', branch = 'release' }
  use 'honza/vim-snippets'
end

function coc.configure()
  g.gutentags_enabled = 1
end

function coc.init(use)
  coc.plugins(use)
  coc.configure()
end

return coc
