-- [nfnl] fnl/_plugins/snacks.fnl
local picker_history = require("phenax.snacks_picker_history")
local sortable_buffers = require("phenax.sortable_buffers")
local core = require("nfnl.core")
local snacks = require("snacks")
local m = {actions = {}}
local plugin
local function _1_()
  return m.config()
end
plugin = {config = _1_, priority = 100, keys = {}}
plugin.config = function()
  local function _2_(self)
    return self:close()
  end
  local function _3_()
    return vim.cmd.startinsert()
  end
  return snacks.setup({bigfile = {enabled = true, size = (1 * 1024 * 1024)}, bufdelete = {enabled = true}, gitbrowse = {enabled = true}, picker = m.picker_config(), quickfile = {enabled = true}, rename = {enabled = true}, styles = {blame_line = {keys = {blame_term_quit = {"q", _2_, mode = "t"}, q = "close"}, on_win = _3_, position = "float"}, phenax_git_diff = {border = "single", style = "blame_line"}}, words = {debounce = 80, enabled = true, modes = {"n"}}})
end
local function _4_()
  return Snacks.bufdelete()
end
local function _5_()
  return Snacks.picker.grep()
end
local function _6_()
  return m.find_files()
end
local function _7_()
  return Snacks.picker.pickers()
end
local function _8_()
  return Snacks.picker.grep_buffers()
end
local function _9_()
  return Snacks.picker.explorer()
end
local function _10_()
  return Snacks.picker.undo()
end
local function _11_()
  return Snacks.picker.spelling()
end
local function _12_()
  return Snacks.picker.resume()
end
local function _13_()
  return Snacks.picker.qflist()
end
local function _14_()
  return Snacks.gitbrowse()
end
local function _15_()
  return Snacks.picker.git_branches()
end
local function _16_()
  return Snacks.picker.git_stash()
end
local function _17_()
  return Snacks.git.blame_line({count = ( - 1)})
end
local function _18_()
  return Snacks.picker.lsp_references()
end
local function _19_()
  return Snacks.picker.lsp_definitions()
end
local function _20_()
  return Snacks.picker.lsp_type_definitions()
end
local function _21_()
  return Snacks.picker.lsp_symbols()
end
plugin.keys = core.concat(sortable_buffers.lazy_keys(), {{"<c-d>", _4_, mode = "n"}, {"<c-f>", _5_, mode = "n"}, {"<leader>f", _6_, mode = "n"}, {"<leader>sp", _7_, mode = "n"}, {"<C-_>", _8_, mode = "n"}, {"<localleader>ne", _9_, mode = "n"}, {"<localleader>uu", _10_, mode = "n"}, {"z=", _11_, mode = "n"}, {"<leader>tr", _12_, mode = "n"}, {"<leader>qf", _13_, mode = "n"}, {"<leader>gb", _14_, mode = {"n", "v"}}, {"<localleader>gbb", _15_, mode = "n"}, {"<localleader>gbs", _16_, mode = "n"}, {"<localleader>gm", _17_, mode = "n"}, {"grr", _18_, mode = "n"}, {"gd", _19_, mode = "n"}, {"gt", _20_, mode = "n"}, {"<localleader>ns", _21_, mode = "n"}})
m.picker_config = function()
  local function _22_()
    local show_preview = (vim.o.columns >= 120)
    return {layout = {{border = "bottom", height = 1, win = "input"}, {{border = "none", win = "list"}, ((show_preview and {border = "none", title = "", width = 0.4, win = "preview"}) or nil), box = "horizontal"}, border = "top", box = "vertical", height = 0.65, row = ( - 1), title = " {title} {live} {flags}", title_pos = "center", width = 0, backdrop = false}}
  end
  local function _23_(picker)
    return picker_history.save_picker(picker)
  end
  return {enabled = true, icons = {files = {enabled = false}}, layout = _22_, on_close = _23_, prompt = " \206\187 ", ui_select = true, win = {input = {keys = m.picker_mappings()}, list = {keys = m.picker_mappings()}}}
end
m.picker_mappings = function()
  return vim.tbl_extend("force", m.select_index_keys(), {["<c-p>"] = {"toggle_preview", mode = {"i", "n"}}})
end
m.find_files = function()
  if Snacks.git.get_root() then
    return Snacks.picker.git_files({untracked = true})
  else
    return Snacks.picker.files()
  end
end
m.select_index_keys = function()
  local keymaps = {}
  for i = 1, 10 do
    local key = i
    if (i == 10) then
      key = 0
    else
    end
    keymaps[("<M-" .. key .. ">")] = {m.actions.highlight_index((i - 1)), mode = {"i", "n"}}
    keymaps[tostring(key)] = {m.actions.open_index((i - 1)), mode = {"n"}}
  end
  return keymaps
end
m.actions.highlight_index = function(index)
  local function _26_()
    local picker = m.current_picker()
    if not picker then
      return 
    else
    end
    return picker.list:_move(((index - picker.list.cursor) + 1))
  end
  return _26_
end
m.actions.open_index = function(index)
  local function _28_()
    local picker = m.current_picker()
    if not picker then
      return 
    else
    end
    picker.list:_move(((index - picker.list.cursor) + 1))
    return picker:action("confirm")
  end
  return _28_
end
m.current_picker = function()
  return Snacks.picker.get()[1]
end
return plugin
