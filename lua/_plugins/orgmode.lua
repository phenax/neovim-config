-- [nfnl] fnl/_plugins/orgmode.fnl
local colors = require("_settings.colors")
local orgmode = require("orgmode")
local orgconfig = require("phenax.orgmode.config")
local orgcapture_templates = require("phenax.orgmode.capture-templates")
local m = {}
local plugin
local function _1_()
  return m.config()
end
plugin = {config = _1_}
m.config = function()
  orgmode.setup({calendar_week_start_day = 0, mappings = m.keybinds(), org_agenda_files = vim.fs.joinpath(orgconfig.path, "**/*.org"), org_agenda_start_on_weekday = 0, org_capture_templates = orgcapture_templates.capture_templates(orgconfig.path), org_deadline_warning_days = 7, org_default_notes_file = orgconfig.notes_entry_file, org_hide_leading_stars = true, org_startup_indented = true, org_todo_keyword_faces = {ACTIVE = (":foreground " .. colors.yellow[200]), BLOCKED = ":foreground gray", CANCELLED = ":foreground gray"}, org_todo_keywords = {"TODO", "ACTIVE", "|", "DONE", "BLOCKED"}, win_split_mode = "25split"})
  local function _2_()
    return m.configure_org_ft()
  end
  vim.api.nvim_create_autocmd("FileType", {callback = _2_, pattern = {"org", "orgagenda"}})
  require("phenax.orgmode.links").initialize()
  return require("phenax.orgmode.present").initialize()
end
m.configure_org_ft = function()
  vim.opt_local.conceallevel = 2
  return nil
end
m.keybinds = function()
  return {agenda = {org_agenda_earlier = "H", org_agenda_goto = "<CR>", org_agenda_goto_date = "J", org_agenda_goto_today = ".", org_agenda_later = "L", org_agenda_switch_to = "<C-Tab>"}, global = {org_agenda = "<leader>oa", org_capture = "<leader>oc"}, org = {org_backward_heading_same_level = "[{", org_change_date = "cid", org_clock_cancel = "<leader>cx", org_clock_in = "<leader>ci", org_clock_out = "<leader>co", org_cycle = "<leader>zza", org_deadline = "<localleader>id", org_forward_heading_same_level = "]}", org_global_cycle = "<leader>zzg", org_insert_todo_heading_respect_content = "<localleader>tn", org_next_visible_heading = "]]", org_open_at_point = "<M-o>", org_previous_visible_heading = "[[", org_schedule = "<localleader>is", org_todo = "<localleader>tt", org_toggle_checkbox = "<localleader>cc"}}
end
return plugin
