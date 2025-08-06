local sortable_buffers = {
  actions = {},
  sorted_buffers = {},
  config = {
    short_name_columns = 45,
  }
}

local clamp = function(n, min, max)
  return math.min(math.max(n, min), max or math.huge)
end

function sortable_buffers.lazy_keys()
  local keys = {
    { mode = 'n', '<localleader>b', function() sortable_buffers.buffer_picker() end },
    { mode = 'n', ']b',             function() sortable_buffers.select_buffer(function(i) return i + 1 end) end },
    { mode = 'n', '[b',             function() sortable_buffers.select_buffer(function(i) return i - 1 end) end },
  }
  for i = 1, 10 do
    local key = i
    if i == 10 then key = 0 end
    table.insert(keys, { mode = 'n', '<localleader>' .. key, function() sortable_buffers.select_buffer(i) end })
  end
  return keys
end

function sortable_buffers.initialize()
  local group = vim.api.nvim_create_augroup('phenax/sortable_buffers', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufHidden', 'BufUnload' }, {
    group = group,
    callback = function() sortable_buffers.populate_buffers() end,
  })
end

function sortable_buffers.mappings()
  return {
    ['<c-d>'] = { sortable_buffers.actions.delete_buffer, mode = { 'i', 'n' } },
    ['dd'] = { sortable_buffers.actions.delete_buffer, mode = 'n' },
    ['<c-j>'] = { sortable_buffers.actions.move_buffer(function(i) return i + 1 end), mode = { 'i', 'n' } },
    ['<c-k>'] = { sortable_buffers.actions.move_buffer(function(i) return i - 1 end), mode = { 'i', 'n' } },
    ['<c-g>g'] = {
      sortable_buffers.actions.move_buffer(function(_) return 1 end),
      mode = { 'i', 'n' },
      nowait = true,
    },
    ['<c-g>G'] = {
      sortable_buffers.actions.move_buffer(function(_) return #sortable_buffers.sorted_buffers end),
      mode = { 'i', 'n' },
      nowait = true,
    },
  }
end

function sortable_buffers.buffer_picker()
  sortable_buffers.populate_buffers()
  local current_buffer = vim.api.nvim_get_current_buf()

  Snacks.picker.pick({
    source = 'sortable_buffers',
    finder = sortable_buffers.finder,
    format = sortable_buffers.formatter,
    title = 'Buffers',
    focus = 'list',
    preview = require 'snacks.picker'.preview.file,
    on_show = function(picker)
      local cur = sortable_buffers.buffer_to_sort_position(current_buffer)
      sortable_buffers.set_selection(picker, cur)
    end,
    win = {
      input = { keys = sortable_buffers.mappings() },
      list = { keys = sortable_buffers.mappings() },
    }
  })
end

function sortable_buffers.finder()
  local results = {}
  for index, buf in ipairs(sortable_buffers.sorted_buffers) do
    local info = vim.fn.getbufinfo(buf)[1];
    local file = info.name ~= '' and info.name or nil
    local bufname = file and vim.fn.fnamemodify(file, ':~:.') or '[No Name]'
    table.insert(results, {
      text = bufname,
      buf = buf,
      index = index,
      changed = info.changed == 1,
      file = bufname,
    })
  end
  return results
end

function sortable_buffers.formatter(entry)
  local segments = vim.split(entry.file, '/')
  local file_short = segments[#segments]
  if #segments > 1 then
    file_short = segments[#segments - 1] .. '/' .. segments[#segments]
  end
  if string.len(file_short) > sortable_buffers.config.short_name_columns then
    file_short = '…' .. string.sub(file_short, -sortable_buffers.config.short_name_columns + 2, -1)
  end
  return {
    { Snacks.picker.util.align(tostring(entry.index), 4),                               'PhenaxBufferIndex' },
    { Snacks.picker.util.align(file_short, sortable_buffers.config.short_name_columns), 'PhenaxBufferShortName' },
    { entry.text,                                                                       entry.changed and 'PhenaxBufferNameChanged' or 'PhenaxBufferName' },
  }
end

function sortable_buffers.select_buffer(pos)
  sortable_buffers.populate_buffers()
  if type(pos) == 'function' then
    local cur = sortable_buffers.buffer_to_sort_position(vim.api.nvim_get_current_buf())
    pos = pos(cur)
    if pos > #sortable_buffers.sorted_buffers then pos = 1 end
    if pos < 1 then pos = #sortable_buffers.sorted_buffers end
  end
  local buf = sortable_buffers.sorted_buffers[pos]
  if buf == nil then return end
  vim.api.nvim_set_current_buf(buf)
end

function sortable_buffers.buffer_to_sort_position(buf)
  for index, value in ipairs(sortable_buffers.sorted_buffers) do
    if buf == value then
      return index
    end
  end
  return #sortable_buffers.sorted_buffers
end

--- @param get_new_index fun(i: number): number
function sortable_buffers.actions.move_buffer(get_new_index)
  local move_buf = function(cur_index, next_index)
    if cur_index < 1 or cur_index > #sortable_buffers.sorted_buffers then return end
    if next_index < 1 or next_index > #sortable_buffers.sorted_buffers then return end
    local buf = sortable_buffers.sorted_buffers[cur_index]
    table.remove(sortable_buffers.sorted_buffers, cur_index)
    table.insert(sortable_buffers.sorted_buffers, next_index, buf)
  end

  return function()
    local picker = sortable_buffers.get_current_picker()
    local pos = picker.list.cursor
    local entry = picker.list:current()
    if not entry then return end

    local cur_index = sortable_buffers.buffer_to_sort_position(entry.buf)
    local is_filtered = pos ~= cur_index
    local next_index = get_new_index(cur_index);
    move_buf(cur_index, clamp(next_index, 1, #sortable_buffers.sorted_buffers))
    sortable_buffers.refresh_picker()
    if not is_filtered then
      sortable_buffers.set_selection(picker, next_index)
    else
      sortable_buffers.set_selection(picker, pos)
    end
  end
end

function sortable_buffers.actions.delete_buffer()
  local picker = sortable_buffers.get_current_picker()
  if not picker then return end

  local entry = picker.list:current()
  if not entry then return end
  local pos = picker.list.cursor
  require 'snacks.picker.actions'.bufdelete(picker)

  sortable_buffers.populate_buffers()
  sortable_buffers.refresh_picker()
  if pos > picker.list:count() then pos = picker.list:count() end
  sortable_buffers.set_selection(picker, pos)
end

function sortable_buffers.set_selection(picker, pos)
  picker.list:view(pos)
end

function sortable_buffers.get_current_picker()
  return Snacks.picker.get()[1]
end

function sortable_buffers.refresh_picker()
  local picker = sortable_buffers.get_current_picker()
  if not picker then return end
  picker:find({ refresh = true })
end

function sortable_buffers.populate_buffers()
  -- Remove unloaded buffers
  sortable_buffers.sorted_buffers = vim.tbl_filter(sortable_buffers.is_buf_valid,
    sortable_buffers.sorted_buffers)

  -- Add new buffers
  local bufnrs = vim.api.nvim_list_bufs()
  for _, buf in ipairs(bufnrs) do
    if sortable_buffers.is_buf_valid(buf) and not vim.tbl_contains(sortable_buffers.sorted_buffers, buf) then
      table.insert(sortable_buffers.sorted_buffers, buf)
    end
  end
end

function sortable_buffers.is_buf_valid(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1
end

return sortable_buffers
