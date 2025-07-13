local M = {
  actions = {},
  sorted_buffers = {},
  config = {
    short_name_columns = 45,
  }
}

local clamp = function(n, min, max)
  return math.min(math.max(n, min), max or math.huge)
end

function M.lazy_keys()
  local keys = {
    { mode = 'n', '<localleader>b', function() M.buffer_picker() end },
    { mode = 'n', ']b',             function() M.select_buffer(function(i) return i + 1 end) end },
    { mode = 'n', '[b',             function() M.select_buffer(function(i) return i - 1 end) end },
  }
  for i = 1, 10 do
    local key = i
    if i == 10 then key = 0 end
    table.insert(keys, { mode = 'n', '<localleader>' .. key, function() M.select_buffer(i) end })
  end
  return keys
end

function M.initialize()
  local group = vim.api.nvim_create_augroup('phenax/telescope_buffers', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufAdd', 'BufDelete', 'BufHidden', 'BufUnload' }, {
    group = group,
    callback = function() M.populate_buffers() end,
  })
end

function M.attach_mappings(map)
  map({ 'i', 'n' }, '<c-d>', M.actions.delete_buffer)
  map({ 'i', 'n' }, '<c-j>', M.actions.move_buffer(function(i) return i + 1 end))
  map({ 'i', 'n' }, '<c-k>', M.actions.move_buffer(function(i) return i - 1 end))
  map({ 'i', 'n' }, '<c-g>g', M.actions.move_buffer(function(_) return 1 end))
  map({ 'i', 'n' }, '<c-g>G', M.actions.move_buffer(function(_) return #M.sorted_buffers end))
end

function M.buffer_picker()
  M.populate_buffers()

  local conf = require 'telescope.config'.values
  require 'telescope.pickers'
      .new({
        layout_config = { preview_cutoff = 190 },
      }, {
        prompt_title = 'Buffers',
        initial_mode = 'normal',
        finder = M.create_finder(),
        previewer = conf.grep_previewer({}),
        preview_title = '',
        sorter = conf.generic_sorter({}),
        default_selection_index = M.buffer_to_sort_position(vim.api.nvim_get_current_buf()),
        attach_mappings = function(_, map)
          M.attach_mappings(map)
          return true
        end,
      })
      :find()
end

function M.select_buffer(pos)
  M.populate_buffers()
  if type(pos) == 'function' then
    local cur = M.buffer_to_sort_position(vim.api.nvim_get_current_buf())
    pos = pos(cur)
    if pos > #M.sorted_buffers then pos = 1 end
    if pos < 1 then pos = #M.sorted_buffers end
  end
  local buf = M.sorted_buffers[pos]
  if buf == nil then return end
  vim.api.nvim_set_current_buf(buf)
end

function M.buffer_to_sort_position(bufnr)
  for index, value in ipairs(M.sorted_buffers) do
    if bufnr == value then
      return index
    end
  end
  return #M.sorted_buffers
end

function M.actions.move_buffer(get_new_index)
  local action_state = require 'telescope.actions.state'

  local move_buf = function(cur_index, next_index)
    if cur_index < 1 or cur_index > #M.sorted_buffers then return end
    if next_index < 1 or next_index > #M.sorted_buffers then return end
    local buf = M.sorted_buffers[cur_index]
    table.remove(M.sorted_buffers, cur_index)
    table.insert(M.sorted_buffers, next_index, buf)
  end

  return function(promptbuf)
    local picker = M.get_current_picker(promptbuf)
    local pos = picker:get_selection_row()
    local entry = action_state.get_selected_entry()
    local cur_index = M.buffer_to_sort_position(entry.bufnr)
    local is_filtered = picker:get_index(pos) ~= cur_index
    local next_index = get_new_index(cur_index);
    move_buf(cur_index, clamp(next_index, 1, #M.sorted_buffers))
    M.refresh_picker(promptbuf)
    if not is_filtered then
      M.set_selection(next_index - 1, promptbuf)
    else
      M.set_selection(pos, promptbuf)
    end
  end
end

function M.actions.delete_buffer(promptbuf)
  -- TODO: reset selection after deletion
  local entry = require 'telescope.actions.state'.get_selected_entry()
  if entry.bufnr then Snacks.bufdelete(entry.bufnr) end
  M.populate_buffers()

  local pos = M.get_current_picker(promptbuf):get_selection_row()
  M.refresh_picker(promptbuf)
  M.set_selection(pos, promptbuf)
end

function M.create_finder()
  local finders = require 'telescope.finders'
  local results = {}
  for index, bufnr in ipairs(M.sorted_buffers) do
    table.insert(results, {
      bufnr = bufnr,
      index = index,
      info = vim.fn.getbufinfo(bufnr)[1],
    })
  end
  return finders.new_table {
    entry_maker = M.create_entry_maker(),
    results = results,
  }
end

function M.display_entry(displayer, entry)
  local segments = vim.split(entry.filename, '/')
  local file_short = segments[#segments]
  if #segments > 1 then
    file_short = segments[#segments - 1] .. '/' .. segments[#segments]
  end
  if string.len(file_short) > M.config.short_name_columns then
    file_short = '…' .. string.sub(file_short, -M.config.short_name_columns + 2, -1)
  end
  return displayer {
    { entry.index,    'PhenaxBufferIndex' },
    { file_short,     'PhenaxBufferShortName' },
    { entry.filename, entry.changed and 'PhenaxBufferNameChanged' or 'PhenaxBufferName' },
  }
end

function M.create_entry_maker()
  local make_entry = require 'telescope.make_entry'
  local entry_display = require 'telescope.pickers.entry_display'
  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { width = 4 },
      { width = M.config.short_name_columns },
      { remaining = true },
    },
  }
  return function(result)
    local filename = result.info.name ~= '' and result.info.name or nil
    local bufname = filename and vim.fn.fnamemodify(filename, ':~:.') or '[No Name]'
    return make_entry.set_default_entry_mt({
      value = bufname,
      ordinal = result.bufnr .. ' : ' .. bufname,
      display = function(entry)
        return M.display_entry(displayer, entry)
      end,
      bufnr = result.bufnr,
      index = result.index,
      path = filename,
      changed = result.info.changed == 1,
      filename = bufname,
    })
  end
end

function M.set_selection(pos, promptbuf)
  vim.defer_fn(function()
    M.get_current_picker(promptbuf):set_selection(pos)
  end, 30)
end

function M.get_current_picker(promptbuf)
  local action_state = require 'telescope.actions.state'
  return action_state.get_current_picker(promptbuf)
end

function M.refresh_picker(promptbuf)
  local current_picker = M.get_current_picker(promptbuf)
  current_picker:refresh(M.create_finder(), { reset_prompt = false })
end

function M.populate_buffers()
  -- Remove unloaded buffers
  M.sorted_buffers = vim.tbl_filter(M.is_buf_valid, M.sorted_buffers)

  -- Add new buffers
  local bufnrs = vim.api.nvim_list_bufs()
  for _, bufnr in ipairs(bufnrs) do
    if M.is_buf_valid(bufnr) and not vim.tbl_contains(M.sorted_buffers, bufnr) then
      table.insert(M.sorted_buffers, bufnr)
    end
  end
end

function M.is_buf_valid(buf)
  return vim.api.nvim_buf_is_valid(buf) and vim.fn.buflisted(buf) == 1
end

return M
