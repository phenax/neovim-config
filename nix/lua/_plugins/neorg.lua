local M = {
  path = vim.fn.expand('~/nixos/extras/notes'),
}

local function space(key)
  return "<LocalLeader>" .. key
end
local function leader(key)
  return "<leader>" .. key
end

function M.setup()
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufRead", "BufNewFile" }, {
    pattern = { "*.norg" },
    callback = M.configure_neorg_file,
  })

  require('neorg').setup(M.get_neorg_config())
end

function M.configure_neorg_file()
  vim.opt.ft = 'norg'
  vim.opt.conceallevel = 2

  vim.api.nvim_set_hl(0, '@neorg.markup.bold', { fg = '#51E980', bold = true })
  vim.api.nvim_set_hl(0, '@neorg.tags.ranged_verbatim.code_block', { bg = '#1a1824' })
end

function M.get_neorg_config()
  return {
    load = {
      ['core.defaults'] = {},
      ['core.export'] = {},
      ['core.export.markdown'] = {},
      -- ['core.integrations.telescope'] = {},
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
            notes = M.path,
            work = M.path .. '/work',
            journal = M.path .. '/journal',
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
          hook = M.neorg_keybindings,
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

function M.neorg_keybindings(keybinds)
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

        -- Notes
        { space 'na', 'core.dirman.new.note' },

        { space 'cn', 'core.itero.next-iteration' },
        { space 'li', 'core.itero.next-iteration' },

        -- Navigation
        { '<Tab>',    'core.integrations.treesitter.next.link' },
        { '<S-Tab>',  'core.integrations.treesitter.previous.link' },
        { ']]',       'core.integrations.treesitter.next.heading' },
        { '[[',       'core.integrations.treesitter.previous.heading' },
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
        { leader 'jn', '<cmd>Neorg journal today<cr>' },
        { leader 'tl', '<cmd>Neorg insert-timelog *<cr>' },
      },
    },
    {
      silent = true,
      noremap = true,
    }
  )

  keybinds.unmap('norg', 'n', '<LocalLeader>nn')
end

return M
