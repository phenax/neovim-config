local utils = require 'utils'
local tools = {}

function tools.plugins(use)
  use 'metakirby5/codi.vim'
end

function tools.configure()
  -- Move line up and down
  utils.xmap('K', ":move '<-2<cr>gv-gv")
  utils.xmap('J', ":move '<+1<cr>gv-gv")

  -- Save
  utils.nnoremap('S', '<nop>')
  utils.nnoremap('SS', ':w<CR>')

  -- Clipboard
  fn.nvim_set_keymap('v', '<C-c>', '"+y', {})

  -- Prevent typo issues
  exec [[map q: <Nop>]]
  exec [[nnoremap Q <nop>]]
  exec [[command! W :w]]
  exec [[command! Q :q]]
  exec [[command! Qa :qa]]
end

return tools
