local utils = require 'utils'
local nmap = utils.nmap

local notes = {
  path = '~/.config/vimwiki/',
  max_fold_level = 20,
  min_fold_level = 1,
}

function notes.plugins(use)
  use {
    'nvim-neorg/neorg',
    -- requires = {
    --   {'nvim-lua/plenary.nvim'},
    --   {'nvim-telescope/telescope.nvim'},
    --   {'nvim-treesitter/nvim-treesitter'},
    -- }
  }
  use 'vimwiki/vimwiki'
  use 'itchyny/calendar.vim'
end

function notes.neorg_config()
  local notes_dir = "~/nixos/extras/notes"
  return {
    load = {
      ["core.defaults"] = {},
      ["core.export"] = {},
      ["core.export.markdown"] = {},
      ["core.norg.completion"] = {
        config = { engine = "nvim-cmp" }
      },
      ["core.norg.qol.toc"] = {},
      -- ["core.presenter"] = {},
      ["core.norg.dirman"] = {
        config = {
          workspaces = {
            personal = notes_dir .. "/personal",
            work = notes_dir .. "/work",
          },
          default_workspace = "personal",
        }
      },
      ["core.norg.journal"] = {
        config = {
          workspace = "personal"
        }
      },
      ["core.gtd.base"] = {
        config = {
          workspace = "work",
        }
      },
      -- ["core.norg.concealer"] = {
      --   config = {
      --     icons = {
      --       todo = { enabled = false },
      --       list = { enabled = false },
      --       link = { enabled = false },
      --       ordered = { enabled = false },
      --     }
      --   },
      -- },
    }
  }
end


function notes__onNewLine(text)
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
  nmap('<localleader>li',  ':lua notes__onNewLine("  * ")<CR>')
  nmap('<localleader>cn',  ':lua notes__onNewLine("  - [ ] ")<CR>')
end

function notes.configure()
  require('neorg').setup(notes.neorg_config())

  g.vimwiki_folding = 'expr'
  g.vimwiki_fold_blank_lines = 0
  g.vimwiki_header_type = '#'
  g.vimwiki_list = {{
    path = notes.path,
    syntax = 'markdown',
    ext = '.md'
  }}

  nmap('<localleader><Tab>', ':lua notes__toggle_foldlevel()<CR>')

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

function notes__toggle_foldlevel()
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

return notes
