-- [nfnl] fnl/phenax/sortable_buffers.fnl
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local not_nil_3f = _local_1_["not_nil?"]
local clamp = _local_1_["clamp"]
local core = require("nfnl.core")
local snacks_picker_actions = require("snacks.picker.actions")
local sortable_buffers = {actions = {}, config = {short_name_columns = 45}, sorted_buffers = {}}
sortable_buffers.initialize = function()
  local function _2_()
    return sortable_buffers.buffer_picker()
  end
  vim.keymap.set("n", "<localleader>b", _2_)
  local function _3_()
    return sortable_buffers.select_buffer(core.inc)
  end
  vim.keymap.set("n", "]b", _3_)
  local function _4_()
    return sortable_buffers.select_buffer(core.dec)
  end
  vim.keymap.set("n", "[b", _4_)
  for i = 1, 10 do
    local key
    if (i == 10) then
      key = 0
    else
      key = i
    end
    local function _6_()
      return sortable_buffers.select_buffer(i)
    end
    vim.keymap.set("n", ("<localleader>" .. key), _6_)
  end
  local group = vim.api.nvim_create_augroup("phenax/sortable_buffers", {clear = true})
  local function _7_()
    return sortable_buffers.populate_buffers()
  end
  return vim.api.nvim_create_autocmd({"BufAdd", "BufDelete", "BufHidden", "BufUnload"}, {callback = _7_, group = group})
end
sortable_buffers.mappings = function()
  local function key(act, opts)
    _G.assert((nil ~= opts), "Missing argument opts on /home/imsohexy/nixos/config/nvim/fnl/phenax/sortable_buffers.fnl:24")
    _G.assert((nil ~= act), "Missing argument act on /home/imsohexy/nixos/config/nvim/fnl/phenax/sortable_buffers.fnl:24")
    return core.merge({act}, opts)
  end
  local function last_index()
    return #sortable_buffers.sorted_buffers
  end
  local function first_index()
    return 1
  end
  return {["<c-d>"] = key(sortable_buffers.actions.delete_buffer, {mode = {"i", "n"}}), ["<c-g>g"] = key(sortable_buffers.actions.move_buffer(first_index), {mode = {"i", "n"}, nowait = true}), ["<c-g>G"] = key(sortable_buffers.actions.move_buffer(last_index), {mode = {"i", "n"}, nowait = true}), ["<c-j>"] = key(sortable_buffers.actions.move_buffer(core.inc), {mode = {"i", "n"}}), ["<c-k>"] = key(sortable_buffers.actions.move_buffer(core.dec), {mode = {"i", "n"}}), dd = key(sortable_buffers.actions.delete_buffer, {mode = "n"})}
end
sortable_buffers.buffer_picker = function()
  sortable_buffers.populate_buffers()
  local current_buffer = vim.api.nvim_get_current_buf()
  local function _8_(picker)
    local cur = sortable_buffers.buffer_to_sort_position(current_buffer)
    return sortable_buffers.set_selection(picker, cur)
  end
  return Snacks.picker.pick({finder = sortable_buffers.finder, focus = "list", format = sortable_buffers.formatter, on_show = _8_, preview = require("snacks.picker").preview.file, source = "sortable_buffers", title = "Buffers", win = {input = {keys = sortable_buffers.mappings()}, list = {keys = sortable_buffers.mappings()}}})
end
sortable_buffers.finder = function()
  local function to_finder_result(_9_)
    local index = _9_[1]
    local buf = _9_[2]
    local info = vim.fn.getbufinfo(buf)[1]
    local file
    if present_3f(info.name) then
      file = info.name
    else
      file = nil
    end
    local bufname = ((file and vim.fn.fnamemodify(file, ":~:.")) or "[No Name]")
    return {buf = buf, changed = (info.changed == 1), file = bufname, index = index, text = bufname}
  end
  return core["map-indexed"](to_finder_result, sortable_buffers.sorted_buffers)
end
sortable_buffers.formatter = function(entry)
  local segments = vim.split(entry.file, "/")
  local file_short = segments[#segments]
  if (#segments > 1) then
    file_short = (segments[(#segments - 1)] .. "/" .. segments[#segments])
  else
  end
  if (string.len(file_short) > sortable_buffers.config.short_name_columns) then
    file_short = ("\226\128\166" .. string.sub(file_short, (( - sortable_buffers.config.short_name_columns) + 2), ( - 1)))
  else
  end
  local align = Snacks.picker.util.align
  local function _13_()
    if entry.changed then
      return "PhenaxBufferNameChanged"
    else
      return "PhenaxBufferName"
    end
  end
  return {{align(tostring(entry.index), 4), "PhenaxBufferIndex"}, {align(file_short, sortable_buffers.config.short_name_columns), "PhenaxBufferShortName"}, {entry.text, _13_()}}
end
sortable_buffers.select_buffer = function(pos)
  sortable_buffers.populate_buffers()
  if core["function?"](pos) then
    local cur = sortable_buffers.buffer_to_sort_position(vim.api.nvim_get_current_buf())
    pos = pos(cur)
    if (pos > #sortable_buffers.sorted_buffers) then
      pos = 1
    else
    end
    if (pos < 1) then
      pos = #sortable_buffers.sorted_buffers
    else
    end
  else
  end
  local buf = sortable_buffers.sorted_buffers[pos]
  if (buf == nil) then
    return 
  else
  end
  return vim.api.nvim_set_current_buf(buf)
end
sortable_buffers.buffer_to_sort_position = function(buf)
  for index, value in ipairs(sortable_buffers.sorted_buffers) do
    if (buf == value) then
      return index
    else
    end
  end
  return #sortable_buffers.sorted_buffers
end
sortable_buffers.actions.move_buffer = function(get_new_index)
  local function move_buf(cur_index, next_index)
    if ((cur_index < 1) or (cur_index > #sortable_buffers.sorted_buffers)) then
      return 
    else
    end
    if ((next_index < 1) or (next_index > #sortable_buffers.sorted_buffers)) then
      return 
    else
    end
    local buf = sortable_buffers.sorted_buffers[cur_index]
    table.remove(sortable_buffers.sorted_buffers, cur_index)
    return table.insert(sortable_buffers.sorted_buffers, next_index, buf)
  end
  local function _21_()
    local picker = sortable_buffers.get_current_picker()
    local pos = picker.list.cursor
    local entry = picker.list:current()
    if not entry then
      return 
    else
    end
    local cur_index = sortable_buffers.buffer_to_sort_position(entry.buf)
    local is_filtered = (pos ~= cur_index)
    local next_index = get_new_index(cur_index)
    move_buf(cur_index, clamp(next_index, 1, #sortable_buffers.sorted_buffers))
    sortable_buffers.refresh_picker()
    if not is_filtered then
      return sortable_buffers.set_selection(picker, next_index)
    else
      return sortable_buffers.set_selection(picker, pos)
    end
  end
  return _21_
end
sortable_buffers.actions.delete_buffer = function()
  local picker = sortable_buffers.get_current_picker()
  if not picker then
    return 
  else
  end
  local entry = picker.list:current()
  if not entry then
    return 
  else
  end
  local pos = picker.list.cursor
  snacks_picker_actions.bufdelete(picker)
  sortable_buffers.populate_buffers()
  sortable_buffers.refresh_picker()
  pos = math.min(pos, picker.list:count())
  return sortable_buffers.set_selection(picker, pos)
end
sortable_buffers.set_selection = function(picker, pos)
  return picker.list:view(pos)
end
sortable_buffers.get_current_picker = function()
  return Snacks.picker.get()[1]
end
sortable_buffers.refresh_picker = function()
  local picker = sortable_buffers.get_current_picker()
  if not_nil_3f(picker) then
    return picker:find({refresh = true})
  else
    return nil
  end
end
sortable_buffers.populate_buffers = function()
  sortable_buffers.sorted_buffers = vim.tbl_filter(sortable_buffers.is_buf_valid, sortable_buffers.sorted_buffers)
  local bufnrs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufnrs) do
    local new_valid_buf_3f = (sortable_buffers.is_buf_valid(buf) and not vim.tbl_contains(sortable_buffers.sorted_buffers, buf))
    if new_valid_buf_3f then
      table.insert(sortable_buffers.sorted_buffers, buf)
    else
    end
  end
  return nil
end
sortable_buffers.is_buf_valid = function(buf)
  return (vim.api.nvim_buf_is_valid(buf) and (vim.fn.buflisted(buf) == 1))
end
return sortable_buffers
