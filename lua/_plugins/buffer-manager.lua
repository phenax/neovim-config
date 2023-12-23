local plugin = {
  'j-morano/buffer_manager.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}

-- Key bindings
plugin.keys = {
  { mode = 'n', '<localleader>b', function() require('buffer_manager.ui').toggle_quick_menu() end, noremap = true },
}
for i = 0, 9 do
  local bidx = i
  if (i == 0) then bidx = 10 end
  table.insert(plugin.keys, {
    mode = 'n',
    '<localleader>' .. i,
    function() require('buffer_manager.ui').nav_file(bidx) end,
    noremap = true,
    silent = true,
  })
end

function plugin.config()
  require('buffer_manager').setup({
    select_menu_item_commands = {
      { key = '<CR>', command = 'edit' },
      { key = '<C-v>', command = 'vsplit' },
      { key = '<C-h>', command = 'split' },
    },
    borderchars = {'','','','','','','',''},
    width = 0.7,
    height = 0.5,
    highlight = 'Normal:BufferManagerBorder',
    win_extra_options = {
      winhighlight = 'Normal:BufferManagerNormal,LineNr:BufferManagerLineNr,Visual:BufferManagerVisual',
    },
  })
end

return plugin
