local plugin = {
  'j-morano/buffer_manager.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}

function plugin.config()
  require('buffer_manager').setup({
    select_menu_item_commands = {
      edit = { key = '<CR>', command = 'edit' },
      v = { key = '<C-v>', command = 'vsplit' },
      h = { key = '<C-h>', command = 'split' },
    },
    borderchars = {'','','','','','','',''},
    width = 0.7,
    height = 0.5,
    highlight = 'Normal:BufferManagerBorder',
    win_extra_options = {
      winhighlight = 'Normal:BufferManagerNormal',
    },
  })

  local bmui = require('buffer_manager.ui')

  vim.keymap.set('n', '<localleader>b', bmui.toggle_quick_menu, { noremap = true })

  for i = 0, 9 do
    local bidx = i
    if (i == 0) then bidx = 10 end
    vim.keymap.set('n',  '<localleader>' .. i, function() bmui.nav_file(bidx) end)
  end
end

return plugin
