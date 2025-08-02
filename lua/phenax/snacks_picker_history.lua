local picker_history = {
  name = 'history_picker',
  max_cached_pickers = 20,
  pickers = {},
}

function picker_history.lazy_keys()
  return {
    { mode = 'n', '<leader>tp', function() picker_history.open() end },
  }
end

function picker_history.save_picker(picker)
  if picker.opts.source == picker_history.name then return end

  picker.opts.pattern = picker.finder.filter.pattern
  picker.opts.search = picker.finder.filter.search
  local opts = picker.opts
  if #picker_history.pickers >= picker_history.max_cached_pickers then
    table.remove(picker_history.pickers, picker_history.max_cached_pickers)
  end
  table.insert(picker_history.pickers, 1, opts)
end

function picker_history.open()
  Snacks.picker.pick({
    source = picker_history.name,
    title = 'History',
    finder = function()
      local results = {}
      for _, picker_opts in ipairs(picker_history.pickers) do
        table.insert(results, { picker_opts = picker_opts })
      end
      return results
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      local old_picker = Snacks.picker.pick(item.picker_opts)
      old_picker.list:update()
      old_picker.input:update()
    end,
    format = function(item, _)
      local source = item.picker_opts.source or 'unknown source'
      local pattern = item.picker_opts.pattern or ''
      local search = item.picker_opts.search or ''
      return {
        { Snacks.picker.util.align(source, 30) },
        { pattern .. (search and (' > ' .. search) or '') },
      }
    end,
    preview = function(ctx)
      ctx.preview:set_title(ctx.item.picker_opts.source)
      ctx.preview:set_lines({
        'Source: ' .. (ctx.item.picker_opts.source or 'unknown'),
        'Pattern: ' .. (ctx.item.picker_opts.pattern or ''),
      })
      ctx.preview:highlight({ ft = 'yaml' })
    end,
  })
end

return picker_history
