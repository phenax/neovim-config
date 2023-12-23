local plugin = {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
}

local config = {}

function plugin.config()
  local theme = require'_settings.theme'
  local lualine = require'lualine'

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = theme.lualine(),
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      always_divide_middle = false,
      globalstatus = true,
    },

    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', {'filename', symbols = { modified = '[●]' }} },
      lualine_c = {'%f'},
      lualine_x = {'%r', 'filetype'},
      lualine_y = {'%m', '%L'},
      lualine_z = {'location'},
    },
  }
end

return plugin
