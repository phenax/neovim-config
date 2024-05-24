local plugin = {
  'nvim-neorg/neorg',
  dependencies = {
    'vhyrro/luarocks.nvim',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
    'nvim-neorg/neorg-telescope',
    'folke/zen-mode.nvim',
    'phenax/neorg-timelog',
    'phenax/neorg-hop-extras',
  },
  version = '*',
  ft = { 'norg' },
}

local config = {
  path = vim.fn.expand '~/nixos/extras/notes',
}

function plugin.config()
  require('neorg').setup(config.get_neorg_config())

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'norg' },
    callback = function() vim.opt.conceallevel = 2 end,
  })
end

function config.get_neorg_config()
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
        },
      },

      ['core.presenter'] = {
        config = {
          zen_mode = 'zen-mode',
        },
      },

      ['core.dirman'] = {
        config = {
          workspaces = {
            notes = config.path,
            work = config.path .. '/work',
            journal = config.path .. '/journal',
          },
          index = 'index.norg',
          default_workspace = 'notes',
          open_last_workspace = false,
          use_popup = false,
        },
      },

      ['core.journal'] = {
        config = {
          workspace = 'journal',
          strategy = 'flat',
          template_name = 'template.norg',
          use_template = true,
        },
      },

      ['core.concealer'] = {
        config = {
          icon_preset = 'basic',
          icons = {
            todo = {
              undone = { icon = ' ' },
            },
            code_block = {
              width = 'content',
              padding = { left = 1, right = 1 },
            },
          },
        },
      },

      ['core.keybinds'] = {
        config = {
          hook = config.neorg_keybindings,
        },
      },

      -- ['core.ui.calendar'] = {}, -- TODO: After nvim 0.10
      ['core.summary'] = {},           -- :Neorg generate-workspace-summary
      ['core.esupports.metagen'] = {}, -- :Neorg inject-metadata | :Neorg update-metadata

      ['external.timelog'] = {},       -- :Neorg insert_timelog <name>
      ['external.hop-extras'] = {},    -- extends <cr> to hop
    },
  }
end

local function space(key) return '<LocalLeader>' .. key end
local function leader(key) return '<leader>' .. key end

function config.neorg_keybindings(keybinds)
  keybinds.map_event_to_mode('norg', {
    n = {
      -- Tasks
      { space 'cu',  'core.qol.todo_items.todo.task_undone' },
      { space 'cp',  'core.qol.todo_items.todo.task_pending' },
      { space 'cd',  'core.qol.todo_items.todo.task_done' },
      { space 'ci',  'core.qol.todo_items.todo.task_important' },
      { space 'ch',  'core.qol.todo_items.todo.task_on_hold' },
      { space 'cc',  'core.qol.todo_items.todo.task_cancelled' },
      { space 'cr',  'core.qol.todo_items.todo.task_recurring' },

      -- GTD views
      { leader 'tt', 'core.integrations.telescope.find_aof_tasks' },
      { leader 'tc', 'core.integrations.telescope.find_context_tasks' },

      -- Notes
      { space 'na',  'core.dirman.new.note' },

      { space 'cn',  'core.itero.next-iteration' },
      { space 'li',  'core.itero.next-iteration' },

      -- Navigation
      { '<Tab>',     'core.integrations.treesitter.next.link' },
      { '<S-Tab>',   'core.integrations.treesitter.previous.link' },
      { ']]',        'core.integrations.treesitter.next.heading' },
      { '[[',        'core.integrations.treesitter.previous.heading' },
      -- { '<cr>',     'core.esupports.hop.hop-link' },
    },
  }, {
    silent = true,
    noremap = true,
  })

  keybinds.map_to_mode('norg', {
    n = {
      -- { space 'cn',  '<cmd>lua Notes__on_new_line("  - ( ) ")<cr>' },
      -- { space 'li',  '<cmd>lua Notes__on_new_line("  - ")<cr>' },
      { leader 'jn', '<cmd>Neorg journal today<cr>' },
      { leader 'th', '<cmd>Telescope neorg search_headings<cr>' },
      { leader 'tf', '<cmd>Telescope neorg find_linkable<cr>' },
      { leader 'ti', '<cmd>Telescope neorg insert_link<cr>' },
      { leader 'tl', '<cmd>Neorg timelog insert *<cr>' }, -- NOTE: Updates all timelogs
    },
  }, {
    silent = true,
    noremap = true,
  })

  keybinds.unmap('norg', 'n', '<LocalLeader>nn')
end

return plugin
