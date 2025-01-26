local colors = require '_settings.colors'

local M = {
  path = vim.fn.expand '~/nixos/extras/notes',
}

local plugin = {
  'nvim-orgmode/orgmode',
  event = 'VeryLazy',
  ft = { 'org' },
  config = function()
    require 'orgmode'.setup {
      org_agenda_files = vim.fs.joinpath(M.path, '**/*.org'),
      org_default_notes_file = vim.fs.joinpath(M.path, 'index.org'),
      org_todo_keywords = { 'TODO', 'ACTIVE', '|', 'DONE', 'BLOCKED' },
      org_todo_keyword_faces = {
        BLOCKED = ':foreground gray',
        ACTIVE = ':foreground ' .. colors.yellow[200],
        CANCELLED = ':foreground gray',
      },
      org_hide_leading_stars = true,
      org_startup_indented = true,
      calendar_week_start_day = 0, -- Start on sunday
      org_agenda_start_on_weekday = 0,
      win_split_mode = '25split',
      org_deadline_warning_days = 7,
      mappings = M.keybinds(),
      org_capture_templates = M.captureTemplates(),
    }

    require 'phenax.orgmodelinks'.setup()

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'org', 'orgagenda' },
      callback = function()
        vim.opt_local.conceallevel = 2
      end,
    })
  end,
}

function M.keybinds()
  return {
    global = {
      org_agenda = '<leader>oa',
      org_capture = '<leader>oc',
    },
    agenda = {
      org_agenda_later = 'L',
      org_agenda_earlier = 'H',
      org_agenda_switch_to = '<C-Tab>',
      org_agenda_goto = '<CR>',
      org_agenda_goto_date = 'J',
      org_agenda_goto_today = '.',
      -- vd,vw,vm,vy : view day,week,month,year
    },
    org = {
      org_change_date = 'cid',
      org_todo = '<localleader>tt',
      org_toggle_checkbox = '<localleader>cc',
      -- org_insert_link = '<localleader>li',
      org_open_at_point = '<M-o>',
      -- org_set_tags_command = '<localleader>cn',
      org_insert_todo_heading_respect_content = '<localleader>tn',
      org_deadline = '<localleader>id',
      org_schedule = '<localleader>is',
      org_clock_in = '<leader>ci',
      org_clock_out = '<leader>co',
      org_clock_cancel = '<leader>cx',
      org_next_visible_heading = ']]',
      org_previous_visible_heading = '[[',
      org_forward_heading_same_level = ']}',
      org_backward_heading_same_level = '[{',
      org_cycle = '<leader>zza',
      org_global_cycle = '<leader>zzg'
    },
  }
end

function M.captureTemplates()
  return {
    d = {
      description = 'Daily',
      target = vim.fs.joinpath(M.path, 'daily/%<%Y-%m>.org'),
      template = [[
* %<%Y-%m-%d> %<%A> :daily:

** What went well today?
- %?

** Challenges
-

** Grateful for?
-

** How are you feeling?
-

** Goals for tomorrow
-

** Feedback/Retro points for work
-


-----

]],
    },

    W = {
      description = 'Work project',
      target = vim.fs.joinpath(M.path, 'projects/work/%^{Project name}.org'),
      template = [[
* %? :work:

*** TODO Planning
**** TODO ?
*** TODO ?

** Maybe

** Resources

** Notes

]],
    },

    P = {
      description = 'Personal project',
      target = vim.fs.joinpath(M.path, 'projects/%^{Project name}.org'),
      template = [[
* %? :project:

*** TODO
- [ ]

** Maybe

** Resources

** Notes

]],
    },
  }
end

return plugin
