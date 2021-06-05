local utils = require 'utils'
local tools = {}

function tools.plugins(use)
  use 'metakirby5/codi.vim'

  -- Search todo,fixme, etc comments
  use 'gilsondev/searchtasks.vim'
end

function tools.configure()
  g.searchtasks_list = {"TODO", "FIXME"} -- :SearchTasks

  -- Move line up and down
  utils.xmap('K', ":move '<-2<cr>gv-gv")
  utils.xmap('J', ":move '<+1<cr>gv-gv")

  -- Save
  utils.nnoremap('S', '<nop>')
  utils.nmap_options('SS', ':w<CR>', { noremap = true, silent = true })

  -- Clipboard
  vim.api.nvim_set_keymap('v', '<C-c>', '"+y', {})

  -- Prevent typo issues
  exec [[map q: <Nop>]]
  exec [[nnoremap Q <nop>]]
  exec [[command! W :w]]
  exec [[command! Q :q]]
  exec [[command! Qa :qa]]

  -- Markdown tagbar
  g.tagbar_type_markdown = tools.get_md_tagbar_config('markdown')
  g.tagbar_type_vimwiki = tools.get_md_tagbar_config('vimwiki')
end

function tools.get_md_tagbar_config(ftype)
  return {
    ctagstype = ftype,
    ctagsbin = '~/.config/nvim/scripts/md2ctags.py',
    ctagsargs = '-f - --sort=yes --sro=»',
    kinds = {
      's:sections',
      'i:images'
    },
    sro = '»',
    kind2scope = {
      s = 'section',
    },
    sort = 0,
  }
end

return tools
