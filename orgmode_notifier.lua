vim.opt.runtimepath:append(vim.fn.stdpath('data') .. '/lazy/orgmode')

local config = dofile(vim.fn.stdpath('config') .. '/lua/phenax/orgmode/config.lua')
local M = {}

function M.init()
  require 'orgmode'.cron({
    org_agenda_files = vim.fs.joinpath(config.path, '**/*.org'),
    org_default_notes_file = config.notes_entry_file,
    notifications = M.notification_options(),
  })
end

function M.notification_options()
  return {
    enabled = false,
    cron_enabled = true,
    deadline_reminder = true,
    scheduled_reminder = true,
    reminder_time = { 2, 15 },
    cron_notifier = function(tasks)
      for _, task in ipairs(tasks) do
        M.send_org_notification(task)
      end
    end,
  }
end

function M.send_org_notification(task)
  local title = task.category .. ' (' .. task.humanized_duration .. ')'
  local subtitle = task.todo .. ' ' .. task.title
  local date = task.type .. ': ' .. task.time:to_string()
  vim.system({
    'notify-send', '--app-name=orgmode',
    title, string.format('%s\n%s', subtitle, date)
  })
end

M.init()
