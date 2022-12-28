local utils = require 'utils'
local nmap = utils.nmap

local notes = {
  path = '~/nixos/extras/notes',
  max_fold_level = 20,
  min_fold_level = 1,
}

function notes.plugins(use)
  use 'vimwiki/vimwiki'
  use {
    'nvim-neorg/neorg',
    -- commit = 'b66bbbf',
    -- tag = '0.0.12',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-treesitter/nvim-treesitter'},
      {'nvim-telescope/telescope.nvim'},
      {'nvim-neorg/neorg-telescope'},
      {'folke/zen-mode.nvim'},
    }
  }
end

local function space(key)
  return "<LocalLeader>" .. key
end
local function leader(key)
  return "<leader>" .. key
end

function notes.neorg_config()
  return {
    load = {
      ['core.defaults'] = {},
      ['core.export'] = {},
      ['core.export.markdown'] = {},
      ['core.integrations.telescope'] = {},
      ['core.norg.qol.toc'] = {},
      ['core.norg.completion'] = {
        config = {
          engine = 'nvim-cmp',
        }
      },

      ['core.presenter'] = {
        config = {
          zen_mode = 'zen-mode'
        },
      },

      ['core.norg.dirman'] = {
        config = {
          workspaces = {
            personal = notes.path .. '/personal',
            work = notes.path .. '/work',
          },
          default_workspace = 'personal',
        }
      },

      ['core.norg.journal'] = {
        config = {
          workspace = 'personal'
        }
      },

      -- ['core.gtd.base'] = {
      --   config = {
      --     workspace = 'work',
      --     inbox = 'index.norg',
      --   }
      -- },

      ['core.norg.concealer'] = {
        config = {
          icons = {
            enabled = false,
          }
        },
      },

      ['core.keybinds'] = {
        config = {
          hook = notes.neorg_keybindings,
        }
      }
    }
  }
end

function notes.neorg_keybindings(keybinds)
  keybinds.map_event_to_mode('norg',
    {
      n = {
        -- Tasks
        { space 'cu', 'core.norg.qol.todo_items.todo.task_undone' },
        { space 'cp', 'core.norg.qol.todo_items.todo.task_pending' },
        { space 'cd', 'core.norg.qol.todo_items.todo.task_done' },
        { space 'ci', 'core.norg.qol.todo_items.todo.task_important' },
        { space 'ch', 'core.norg.qol.todo_items.todo.task_on_hold' },
        { space 'cc', 'core.norg.qol.todo_items.todo.task_cancelled' },
        { space 'cr', 'core.norg.qol.todo_items.todo.task_recurring' },

        -- GTD views
        { leader 'tv', 'core.gtd.base.views' },
        { leader 'te', 'core.gtd.base.edit' },

        -- Notes
        { space 'na', 'core.norg.dirman.new.note' },

        -- Navigation
        { '<Tab>',    'core.integrations.treesitter.next.link' },
        { '<S-Tab>',  'core.integrations.treesitter.previous.link' },
        -- { '<cr>',     'core.norg.esupports.hop.hop-link' },
      },
    },
    {
      silent = true,
      noremap = true,
    }
  )

  keybinds.map_to_mode('norg',
    {
      n = {
        { space 'cn',  '<cmd>lua Notes__on_new_line("  - [ ] ")<cr>' },
        { leader 'jn', '<cmd>Neorg journal today<cr>' },
        { leader 'tp', '<cmd>Telescope neorg find_project_tasks<cr>' },
        { leader 'tc', '<cmd>Telescope neorg find_context_tasks<cr>' },
        { leader 'tf', '<cmd>Telescope neorg find_linkable<cr>' },
        { leader 'ti', '<cmd>Telescope neorg insert_link<cr>' },
      },
    },
    {
      silent = true,
      noremap = true,
    }
  )

  keybinds.unmap('norg', 'n', '<LocalLeader>nn')
end

function Notes__on_new_line(text)
  -- TODO: Refactor to lua sometime maybe?
  exec('call append(".", "'..text..'")')
  exec [[normal! j$]]
  exec [[startinsert!]]
end

function Notes__onvimwiki()
  -- Diary
  nmap('<localleader>da',  ':VimwikiMakeDiaryNote<CR>')
  nmap('<localleader>dx',  ':VimwikiDiaryGenerateLinks<CR>')
  nmap('<localleader>di',  '<leader>wi')
  -- Checklist
  nmap('<localleader>cc',  ':VimwikiToggleListItem<CR>')
  nmap('<localleader>li',  ':lua Notes__on_new_line("  * ")<CR>')
  nmap('<localleader>cn',  ':lua Notes__on_new_line("  - [ ] ")<CR>')
end

function notes.configure()
  require("zen-mode").setup {
    window = {
      backdrop = 1,
      width = .50,
      height = .80,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        cursorline = false,
        cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
  }
  require('neorg').setup(notes.neorg_config())

  g.vimwiki_folding = 'expr'
  g.vimwiki_fold_blank_lines = 0
  g.vimwiki_header_type = '#'
  g.vimwiki_list = {{
    path = notes.path,
    syntax = 'markdown',
    ext = '.md'
  }}

  nmap('<leader><Tab>', ':lua Notes__toggle_foldlevel()<CR>')

  nmap('<leader>==', ':setlocal spell! spelllang=en_us<CR>')
  nmap('z=', ':Telescope spell_suggest<CR>')

  exec [[au BufRead,BufNewFile *.md set filetype=vimwiki]]
  exec [[autocmd FileType vimwiki,markdown lua Notes__onvimwiki()]]
end

function Notes__toggle_foldlevel()
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
