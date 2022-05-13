local utils = require 'utils'
local updateScheme = utils.updateScheme

local theme = {
  colorscheme = 'material', -- xresources
  lightline_theme = 'palenight',
}

function theme.plugins(use)
  use 'phenax/palenight.vim'
  use 'ryanoasis/vim-devicons'
  use 'kyazdani42/nvim-web-devicons'
  use { 'kaicataldo/material.vim', branch = 'main' }

  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
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

  theme.lightline()
  theme.tabs()
  theme.lsptheme()

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
  })
end

function theme.tabs()
  o.showtabline = 2

  g["lightline#bufferline#show_number"] = 2
  g["lightline#bufferline#number_separator"] = ': '
  g["lightline#bufferline#read_only"] = ' 🔒 '
  g["lightline#bufferline#modified"] = ' 🛑 '
  g["lightline#bufferline#enable_devicons"] = 1
  g["lightline#bufferline#filename_modifier"] = ':t'
end

function theme.lightline()
  g.lightline = {
    colorscheme = theme.lightline_theme,
    enable = {
      statusline = 1,
      tabline = 1,
    },
    active = {
      left = {
         { 'mode' },
         { 'gitbranch', 'readonly' },
         { 'filename', 'dir' },
      },
      right = {
         { 'lineinfo' },
         { 'total_lines' },
         { 'filetype' },
      },
    },
    component = {
      lineinfo = 'L %3l:%-2v',
      dir = '%F',
      total_lines = '[%L]',
    },
    component_function = {
      gitbranch = 'FugitiveHead',
    },
    component_type = { buffers = 'tabsel' },
    tabline = { left = { {'buffers'} }, right = { {} } },
    tab = {
      active = { 'tabnum', 'filename', 'modified' },
      inactive = { 'tabnum', 'filename', 'modified' },
    },
    component_expand = {
      buffers = 'lightline#bufferline#buffers'
    }
  };
end

return theme;
