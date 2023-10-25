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
    'lukas-reineke/headlines.nvim',
    requires = { 'nvim-treesitter/nvim-treesitter' },
  }
  use {
    'nvim-neorg/neorg',
    run = ':Neorg sync-parsers',
    -- after = 'nvim-treesitter',
    -- commit = 'b66bbbf',
    -- tag = '0.0.12',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-treesitter/nvim-treesitter'},
      {'nvim-telescope/telescope.nvim'},
      {'nvim-neorg/neorg-telescope'},
      {'folke/zen-mode.nvim'},
      {'phenax/neorg-timelog'},
      {'phenax/neorg-hop-extras'},
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
      ['core.qol.toc'] = {},
      ['core.completion'] = {
        config = {
          engine = 'nvim-cmp',
        }
      },

      ['core.presenter'] = {
        config = {
          zen_mode = 'zen-mode'
        },
      },

      ['core.dirman'] = {
        config = {
          workspaces = {
            notes = notes.path,
            work = notes.path .. '/work',
            journal = notes.path .. '/journal',
          },
          index = 'index.norg',
          default_workspace = 'notes',
          open_last_workspace = false,
          use_popup = false,
        }
      },

      ['core.journal'] = {
        config = {
          workspace = 'journal',
          strategy = 'flat',
          template_name = 'template.norg',
          use_template = true,
        }
      },

      -- ['core.gtd.base'] = {
      --   config = {
      --     workspace = 'work',
      --     inbox = 'index.norg',
      --   }
      -- },

      ['core.concealer'] = {
        config = {
          icon_preset = 'basic',
          icons = {
            todo = {
              undone = { icon = ' ' },
            },
            code_block = {
              width = "content",
              padding = { left = 1, right = 1 },
            },
          }
        },
      },

      ['core.keybinds'] = {
        config = {
          hook = notes.neorg_keybindings,
        }
      },

      -- ['core.ui.calendar'] = {}, -- TODO: After nvim 0.10
      ['core.summary'] = {}, -- :Neorg generate-workspace-summary
      ['core.esupports.metagen'] = {}, -- :Neorg inject-metadata | :Neorg update-metadata

      ['external.timelog'] = {}, -- :Neorg insert_timelog <name>
      ['external.hop-extras'] = {}, -- extends <cr> to hop
    }
  }
end

function notes.neorg_keybindings(keybinds)
  keybinds.map_event_to_mode('norg',
    {
      n = {
        -- Tasks
        { space 'cu', 'core.qol.todo_items.todo.task_undone' },
        { space 'cp', 'core.qol.todo_items.todo.task_pending' },
        { space 'cd', 'core.qol.todo_items.todo.task_done' },
        { space 'ci', 'core.qol.todo_items.todo.task_important' },
        { space 'ch', 'core.qol.todo_items.todo.task_on_hold' },
        { space 'cc', 'core.qol.todo_items.todo.task_cancelled' },
        { space 'cr', 'core.qol.todo_items.todo.task_recurring' },

        -- GTD views
        { leader 'tt', 'core.integrations.telescope.find_aof_tasks' },
        { leader 'tc', 'core.integrations.telescope.find_context_tasks' },

        -- Notes
        { space 'na', 'core.dirman.new.note' },

        { space 'cn', 'core.itero.next-iteration' },
        { space 'li', 'core.itero.next-iteration' },

        -- Navigation
        { '<Tab>',    'core.integrations.treesitter.next.link' },
        { '<S-Tab>',  'core.integrations.treesitter.previous.link' },
        { ']]',       'core.integrations.treesitter.next.heading' },
        { '[[',       'core.integrations.treesitter.previous.heading' },
        -- { '<cr>',     'core.esupports.hop.hop-link' },
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
        -- { space 'cn',  '<cmd>lua Notes__on_new_line("  - ( ) ")<cr>' },
        -- { space 'li',  '<cmd>lua Notes__on_new_line("  - ")<cr>' },
        { leader 'jn', '<cmd>Neorg journal today<cr>' },
        { leader 'th', '<cmd>Telescope neorg search_headings<cr>' },
        { leader 'tf', '<cmd>Telescope neorg find_linkable<cr>' },
        { leader 'ti', '<cmd>Telescope neorg insert_link<cr>' },
        { leader 'tl', '<cmd>Neorg insert-timelog *<cr>' }, -- NOTE: Updates all timelogs
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
  -- Checklist - V:s/- \[ \] /- [x] /|noh
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

  -- FIXME: Temporary workaround for filetype in neorg
  vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.norg" },
    callback = function()
      vim.opt.ft = 'norg'
      vim.opt.conceallevel = 2
      exec [[hi @neorg.markup.bold guifg=#51E980 gui=bold]]
    end,
  })
  vim.api.nvim_set_hl(0, '@neorg.tags.ranged_verbatim.code_block', { bg = '#1a1824' })
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

  require('headlines').setup({
    norg = {
      headline_highlights = { "Headline" },
      codeblock_highlight = false,
      dash_highlight = "Dash",
      dash_string = "-",
      doubledash_highlight = "DoubleDash",
      doubledash_string = "=",
      quote_highlight = false,
      fat_headlines = false,
      -- fat_headline_upper_string = "▃",
      -- fat_headline_lower_string = "▀",
    },
  })
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
