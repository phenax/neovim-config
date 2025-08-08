-- [nfnl] fnl/phenax/snacks_picker_history.fnl
local core = require("nfnl.core")
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local picker_history = {max_cached_pickers = 20, name = "history_picker", pickers = {}}
picker_history.initialize = function()
  local function _2_()
    return picker_history.open()
  end
  return vim.keymap.set("n", "<leader>tp", _2_)
end
picker_history.save_picker = function(picker)
  if (picker.opts.source == picker_history.name) then
    return 
  else
  end
  picker.opts.pattern = picker.finder.filter.pattern
  picker.opts.search = picker.finder.filter.search
  if (#picker_history.pickers >= picker_history.max_cached_pickers) then
    table.remove(picker_history.pickers, picker_history.max_cached_pickers)
  else
  end
  return table.insert(picker_history.pickers, 1, picker.opts)
end
picker_history.open = function()
  local function _5_(picker, item)
    return picker_history.confirm(picker, item)
  end
  local function _6_()
    return picker_history.finder()
  end
  local function _7_(item, _)
    return picker_history.format(item)
  end
  local function _8_(ctx)
    return picker_history.preview(ctx)
  end
  return Snacks.picker.pick({confirm = _5_, finder = _6_, format = _7_, preview = _8_, source = picker_history.name, title = "History"})
end
picker_history.finder = function()
  local function _9_(picker)
    return {picker_opts = picker}
  end
  return core.map(_9_, picker_history.pickers)
end
picker_history.format = function(item, _)
  local source = (item.picker_opts.source or "unknown source")
  local pattern = (item.picker_opts.pattern or "")
  local search = (item.picker_opts.search or "")
  local _10_
  if present_3f(search) then
    _10_ = (" > " .. search)
  else
    _10_ = ""
  end
  return {{Snacks.picker.util.align(source, 30)}, {(pattern .. _10_)}}
end
picker_history.preview = function(ctx)
  local source = (ctx.item.picker_opts.source or "unknown")
  local pattern = (ctx.item.picker_opts.pattern or "")
  ctx.preview:set_title(source)
  ctx.preview:set_lines({("Source: " .. source), ("Pattern: " .. pattern)})
  return ctx.preview:highlight({ft = "yaml"})
end
picker_history.confirm = function(picker, _3fitem)
  picker:close()
  if present_3f(_3fitem) then
    local old_picker = Snacks.picker.pick(_3fitem.picker_opts)
    old_picker.list:update()
    return old_picker.input:update()
  else
    return nil
  end
end
return picker_history
