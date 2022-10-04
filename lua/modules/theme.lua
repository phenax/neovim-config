local utils = require 'utils'
local updateScheme = utils.updateScheme

local theme = {
  colorscheme = 'material',
}

function theme.plugins(use)
  -- use 'phenax/palenight.vim'
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
  use { 'kaicataldo/material.vim', branch = 'main' }

  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
end

function theme.configure(use)
  --exec('colorscheme ' .. (theme.colorscheme))
  g.material_terminal_italics = 1
  g.material_theme_style = 'ocean'

  o.background = "dark"
  g.base16colorspace = 256

  -- vim.go.t_Co = "256"

  updateScheme({
    'Normal guibg=NONE ctermbg=NONE',
    'ColorColumn guibg=#15121f',
  })

  -- g['$NVIM_TUI_ENABLE_TRUE_COLOR'] = 1
  if vim.fn.has("termguicolors") then
    vim.go.t_8f = "[[38;2;%lu;%lu;%lum"
    vim.go.t_8b = "[[48;2;%lu;%lu;%lum"
    vim.go.termguicolors = true
  end

  theme.lsptheme()
  theme.lualine()

  exec('colorscheme ' .. (theme.colorscheme))
end

function theme.lsptheme()
  local lensColors = {
    Error = "#db4b4b",
    Warn = "#ffaf68",
    Info = "#d0bf78",
    Hint = "#513970",
    Lens = "#513970",
  }

  updateScheme({
    'DiagnosticError guifg=' .. lensColors.Error,
    'DiagnosticWarn guifg=' .. lensColors.Warn,
    'DiagnosticInfo guifg=' .. lensColors.Info,
    'DiagnosticHint guifg=' .. lensColors.Hint,
    'DiagnosticUnderlineError guifg=' .. lensColors.Error,
    'DiagnosticUnderlineWarn guifg=' .. lensColors.Warn,
    'DiagnosticUnderlineInfo guifg=' .. lensColors.Info,
    'DiagnosticUnderlineHint guifg=' .. lensColors.Hint,
    'LspCodeLens guifg=' .. lensColors.Lens,
    'LspSignatureActiveParameter guifg=' .. lensColors.Info,
  })
end

function theme.lualine()
  local lualine = require'lualine'
  local theme = require'lualine.themes.iceberg_dark'

  local colors = {
    dark = {
      '#0f0c19',
      '#15121f',
    },
    purple = '#4e3aA3',
    white = '#ffffff',
    fadedwhite = '#bbc0d9',
    gray = {
      '#7b8099',
      '#3e445e',
    }
  }

  theme.normal.a = { bg = colors.purple, fg = colors.white, gui = 'bold' }
  theme.inactive.a = { bg = colors.dark[2], fg = colors.gray[1] }

  local bline = { bg = colors.dark[2], fg = colors.gray[1] }
  theme.normal.b = bline
  theme.insert.b = bline
  theme.visual.b = bline
  theme.replace.b = bline
  theme.inactive.b = bline

  local cline = { bg = colors.dark[1], fg = colors.gray[2] }
  theme.normal.c = cline
  theme.insert.c = cline
  theme.visual.c = cline
  theme.replace.c = cline
  theme.inactive.c = cline

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = theme,
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
end

return theme;
