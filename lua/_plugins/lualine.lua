local plugin = {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'kyazdani42/nvim-web-devicons',
  },
}

local config = {}

function plugin.config()
  local lualine = require'lualine'

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = config.get_theme(),
      component_separators = { left = '', right = ''},
      section_separators = { left = '', right = ''},
      always_divide_middle = false,
      globalstatus = true,
    },

    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'filename'},
      lualine_c = {'%f'},
      lualine_x = {'%r', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'},
    },

    tabline = {
      lualine_a = {
        {
          'buffers',
          mode = 2,
          max_length = vim.o.columns,
          filetype_names = {
            TelescopePrompt = '<telescope>',
            fugitive = '<git>',
            NvimTree = '<dir>',
            Trouble = '<diagnostic>',
          },
          symbols = {
            alternate_file = '',
          },
        },
      },
      lualine_b = {},
      lualine_c = {},
      lualine_x = {},
      lualine_y = {},
      lualine_z = {},
    },
  }

  for i = 0, 9 do
    local bidx = i
    if (i == 0) then bidx = 10 end
    vim.keymap.set('n',  '<localleader>' .. i, ':LualineBuffersJump! '.. bidx ..'<CR>')
  end
end

function config.get_theme()
  local colors = {
    dark = {
      '#0f0c19',
      '#15121f',
    },
    purple = '#4e3aA3',
    red = '#7c162e',
    white = '#ffffff',
    fadedwhite = '#bbc0d9',
    gray = {
      '#7b8099',
      '#3e445e',
    }
  }

  local thm = require'lualine.themes.iceberg_dark'

  thm.normal.a = { bg = colors.purple, fg = colors.white, gui = 'bold' }
  thm.inactive.a = { bg = colors.dark[2], fg = colors.gray[1] }

  local bline = { bg = colors.dark[2], fg = colors.gray[1] }
  thm.normal.b = bline
  thm.insert.b = bline
  thm.visual.b = bline
  thm.replace.b = bline
  thm.inactive.b = bline

  local cline = { bg = colors.dark[1], fg = colors.gray[2] }
  thm.normal.c = cline
  thm.insert.c = cline
  thm.visual.c = cline
  thm.replace.c = cline
  thm.inactive.c = cline

  return thm
end

return plugin
