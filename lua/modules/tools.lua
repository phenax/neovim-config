local utils = require 'utils'
local tools = {}

function tools.plugins(use)
  -- use 'metakirby5/codi.vim'
  -- use 'ciaranm/detectindent'
  --use 'editorconfig/editorconfig-vim'

  -- Search todo,fixme, etc comments
  use 'gilsondev/searchtasks.vim'

  -- Interactive scratchpad
  use 'metakirby5/codi.vim'
end

function tools.configure()
  g.searchtasks_list = {"TODO", "FIXME"} -- :SearchTasks

  -- exec [[autocmd BufEnter * :DetectIndent]]

  -- Move line up and down
  utils.xmap('K', ":move '<-2<cr>gv-gv")
  utils.xmap('J', ":move '<+1<cr>gv-gv")

  -- Copy file path
  exec [[command! CpPath :let @+=expand("%")]]
  exec [[command! CpPathAbs :let @+=expand("%:p")]]

  -- Save
  utils.nnoremap('S', '<nop>')
  utils.nmap_options('SS', ':w<CR>', { noremap = true, silent = true })
  utils.nmap_options('<C-s>', ':w<CR>', { noremap = true, silent = true })

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

function SetIndent(indent)
  exec(":set shiftwidth=".. indent .." expandtab")
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
