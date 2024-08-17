local plugin = {
  'nvim-neorg/neorg',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-telescope/telescope.nvim',
    'nvim-neorg/neorg-telescope',
    -- 'phenax/neorg-timelog',
    'phenax/neorg-hop-extras',
  },
  -- version = '*',
  -- commit = "8635908dd793a88031735ec2eaedf97292bc3ea9",
  ft = { 'norg' },
}

local config = {
  path = vim.fn.expand '~/nixos/extras/notes',
}

function plugin.config()
  require('neorg').setup(config.get_neorg_config())

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'norg' },
    callback = function()
      vim.opt.conceallevel = 2
      config.neorg_keybindings()
    end,
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

      ['core.ui.calendar'] = {},
      ['core.summary'] = {},           -- :Neorg generate-workspace-summary
      ['core.esupports.metagen'] = {}, -- :Neorg inject-metadata | :Neorg update-metadata
      -- ['core.text-objects'] = {},

      -- ['external.timelog'] = {},    -- :Neorg insert_timelog <name>
      ['external.hop-extras'] = {}, -- extends <cr> to hop
    },
  }
end

local function space(key) return '<localleader>' .. key end
local function leader(key) return '<leader>' .. key end

local keybindings = function(mappings)
  for mode, mode_map in pairs(mappings) do
    for k, v in pairs(mode_map) do
      vim.keymap.set(mode, k, v, {
        silent = true,
        noremap = true,
        buffer = true,
      })
    end
  end
end

function config.neorg_keybindings()
  -- vim.keymap.del('n', '<LocalLeader>nn', { buffer = true })
  keybindings {
    n = {
      -- Tasks
      [space 'cu'] = '<plug>(neorg.qol.todo-items.todo.task-undone)',
      [space 'cp'] = '<plug>(neorg.qol.todo-items.todo.task-pending)',
      [space 'cd'] = '<plug>(neorg.qol.todo-items.todo.task-done)',
      [space 'ci'] = '<plug>(neorg.qol.todo-items.todo.task-important)',
      [space 'ch'] = '<plug>(neorg.qol.todo-items.todo.task-on-hold)',
      [space 'cc'] = '<plug>(neorg.qol.todo-items.todo.task-cancelled)',
      [space 'cr'] = '<plug>(neorg.qol.todo-items.todo.task-recurring)',

      -- Notes
      [space 'na'] = '<plug>(neorg.dirman.new.note)',
      [space 'cn'] = '<plug>(neorg.itero.next-iteration)',
      [space 'li'] = '<plug>(neorg.itero.next-iteration)',

      -- Defaults
      -- <localleader>id -> insert date
      -- <localleader>cm -> open code block inside split buffer

      -- Navigation
      ['<Tab>'] = '<plug>(neorg.treesitter.next.link)',
      ['<S-Tab>'] = '<plug>(neorg.treesitter.previous.link)',
      [']]'] = '<plug>(neorg.treesitter.next.heading)',
      ['[['] = '<plug>(neorg.treesitter.previous.heading)',
      -- ['<cr>'] = 'neorg.esupports.hop.hop-link',

      [leader 'jn'] = '<cmd>Neorg journal today<cr>',
      [leader 'tf'] = '<cmd>Telescope neorg insert_file_link<cr>',
      [leader 'tt'] = '<plug>(neorg.telescope.backlinks.file_backlinks)',

      [leader 'tl'] = '<cmd>Neorg timelog insert *<cr>', -- NOTE: Updates all timelogs
    },
  }
end

return plugin
