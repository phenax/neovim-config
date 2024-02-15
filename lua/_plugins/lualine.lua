local plugin = {
  'nvim-lualine/lualine.nvim',
  -- enabled = false,
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
}

function plugin.config()
  local theme = require '_settings.theme'
  local lualine = require 'lualine'

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = theme.get_lualine_theme(),
      component_separators = { left = '', right = '' },
      section_separators = { left = '', right = '' },
      always_divide_middle = false,
      globalstatus = false,
      disabled_filetypes = {
        winbar = { 'fugitive', 'NvimTree', 'aerial', 'fugitiveblame', 'Trouble' },
      },
    },

    sections = {},
    inactive_sections = {},
    tabline = {},

    inactive_winbar = {
      lualine_c = { { 'filename', path = 4, symbols = { modified = '[● modified]' } } },
      lualine_x = { '%r', '%m', 'filetype' },
    },

    winbar = {
      lualine_a = { {
        'filename',
        path = 4,
        symbols = { modified = '●' },
        color = function(_)
          if not vim.bo.modified then return nil end
          return { gui = 'bold' }
        end,
      }, },
      lualine_b = { 'branch' },
      lualine_c = {},
      lualine_x = { '%r', '%m' },
      lualine_y = { 'filetype' },
      lualine_z = { '%l/%L' },
      -- lualine_a = { 'mode' },
      -- lualine_b = { 'branch', filename },
      -- lualine_c = {},
      -- lualine_x = { '%r', 'filetype' },
      -- lualine_y = { '%m', '%L' },
      -- lualine_z = { 'location' },
    },
  }

  -- Disable statusline
  vim.o.statusline = '%#@_phenax.statusline#'
end

return plugin
