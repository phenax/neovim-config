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

  theme.telescope()

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
  local thm = require'lualine.themes.iceberg_dark'

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

  lualine.setup {
    options = {
      icons_enabled = true,
      theme = thm,
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
        -- {
        --   'filename',
        --   file_status = true,
        --   newfile_status = true,
        --   path = 1,
        --   -- shorting_target = 40,
        --   symbols = {
        --     modified = '[+]',
        --     readonly = '[-]',
        --     unnamed = '<no name>',
        --     newfile = '<new>',
        --   }
        -- },
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
      lualine_y = {
        'filetype'
      },
      lualine_z = {},
    },
  }
end

function theme.telescope()
  -- local bg = '#0f0c19'
  local bgfaded = '#110f1b'
  local bgfaded2 = '#1a1824'
  local accent = '#4e3aA3'

  local blend = function(c)
    return 'guibg=' .. c .. ' guifg=' .. c
  end

  updateScheme({
    'TelescopeNormal guibg=' .. bgfaded,
    'TelescopeBorder ' .. blend(bgfaded),

    'TelescopePreviewNormal guibg=' .. bgfaded,
    'TelescopePreviewTitle guibg=' .. accent .. ' guifg=#ffffff',

    'TelescopeResultsTitle ' .. blend(bgfaded),

    'TelescopePromptNormal guibg=' .. bgfaded2,
    'TelescopePromptTitle guibg=' .. accent .. ' guifg=#ffffff',
    'TelescopePromptBorder ' ..  blend(bgfaded2),
    'TelescopePromptPrefix guibg=' .. bgfaded2,
  })

  -- vim.api.nvim_command('autocmd FileType buffer_manager highlight Normal guibg=' .. bgfaded2 .. '')
end

return theme;
