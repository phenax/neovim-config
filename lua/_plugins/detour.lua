local plugin = {
  'carbon-steel/detour.nvim',
  keys = {
    { '<c-w>.', ':DetourCurrentWindow<cr>', mode = 'n' },
  },
}

function plugin.config()
end

return plugin
