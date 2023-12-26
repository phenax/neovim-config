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
      theme = theme.get_lualine_theme(),
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      always_divide_middle = false,
      globalstatus = true,
      disabled_filetypes = {
        winbar = { 'fugitive', 'NvimTree', 'aerial', 'fugitiveblame', 'Trouble' },
      },
    },

    sections = {},
    inactive_sections = {},

    inactive_winbar = {
      lualine_c = { { 'filename', path = 4, symbols = { modified = '[● modified]' } } },
      lualine_x = {'%r', 'filetype'},
    },
    winbar = {
      lualine_a = {'mode'},
      lualine_b = {'branch', { 'filename', path = 4, symbols = { modified = '[● modified]' } } },
      lualine_c = {},
      lualine_x = {'%r', 'filetype'},
      lualine_y = {'%m', '%L'},
      lualine_z = {'location'},
    },
  }

  -- Disable statusline
  vim.o.laststatus = 0
  vim.cmd [[ let &statusline='%#@_phenax.statusline#' ]]
end

return plugin
