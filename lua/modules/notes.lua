local utils = require 'utils'
local nmap = utils.nmap

local notes = {
  path = '~/.config/vimwiki/',
  max_fold_level = 20,
  min_fold_level = 1,
}

function notes.plugins(use)
  use 'vimwiki/vimwiki'
  use 'itchyny/calendar.vim'
end


function onNewLine(text)
  -- TODO: Refactor to lua sometime maybe?
  exec('call append(".", "'..text..'")')
  exec [[normal! j$]]
  exec [[startinsert!]]
end

function notes__onvimwiki()
  -- Diary
  nmap('<localleader>da',  ':VimwikiMakeDiaryNote<CR>')
  nmap('<localleader>dx',  ':VimwikiDiaryGenerateLinks<CR>')
  nmap('<localleader>di',  '<leader>wi')

  -- Checklist
  nmap('<localleader>cc',  ':VimwikiToggleListItem<CR>')
  nmap('<localleader>li',  ':lua onNewLine("  * ")<CR>')
  nmap('<localleader>cn',  ':lua onNewLine("  - [ ] ")<CR>')
end

function toggle_foldlevel()
  local max_level = notes.max_fold_level
  local min_level = notes.min_fold_level

  if (vim.opt.foldlevel._value >= max_level) then
    exec [["normal! zM<CR>]]
    vim.opt.foldlevel = min_level
  else
    exec [["normal! zR<CR>]]
    vim.opt.foldlevel = max_level
  end
end

function notes.configure()
  g.vimwiki_folding = 'expr'
  g.vimwiki_fold_blank_lines = 0
  g.vimwiki_header_type = '#'
  g.vimwiki_list = {{
    path = notes.path,
    syntax = 'markdown',
    ext = '.md'
  }}

  nmap('<localleader><Tab>', ':lua toggle_foldlevel()<CR>')

  nmap('<leader>==', ':setlocal spell! spelllang=en_us<CR>')

  exec [[au BufRead,BufNewFile *.md set filetype=vimwiki]]
  exec [[autocmd FileType vimwiki,markdown lua notes__onvimwiki()]]

  -- URL editor commands
  nmap('<localleader>hts', ':s/http:/https:/g<CR>') -- http to https

  -- Calender/clock
  exec [[command! Cal :Calendar -split=vertical]]
  exec [[command! Clock :Calendar -split=horizontal -view=clock]]
  nmap('<localleader>cal', ':Cal<CR>')
end

return notes

