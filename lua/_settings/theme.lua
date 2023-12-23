function updateScheme(schemes)
  for k, v in pairs(schemes) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

local theme = {}

function theme.setup(colorscheme)
  vim.o.background = 'dark'
  vim.g.base16colorspace = 256

  if vim.fn.has('termguicolors') then
    vim.go.t_8f = '[[38;2;%lu;%lu;%lum'
    vim.go.t_8b = '[[48;2;%lu;%lu;%lum'
    vim.go.termguicolors = true
  end

  vim.cmd('colorscheme ' .. colorscheme)

  updateScheme {
    Normal = { bg = 'NONE', fg = '#b8bec9' },
    ColorColumn = { bg = '#15121f' },
  }

  theme.telescope()
  theme.buffer_manager()
  theme.lsp()
end

function theme.buffer_manager()
  local bgfaded = '#110f1b'
  local bgfaded2 = '#1a1824'
  local bgfaded3 = '#2a2834'
  local accent = '#4e3aA3'
  local fg = '#ffffff'
  local fg2 = '#8a8894'
  local fg3 = '#4a4854'

  updateScheme {
    BufferManagerModified = { fg = accent },
    BufferManagerNormal = { bg = bgfaded2, fg = fg2 },
    BufferManagerBorder = { bg = bgfaded2, fg = bgfaded2 },
    BufferManagerLineNr = { bg = bgfaded2, fg = fg },
    BufferManagerVisual = { bg = bgfaded3, fg = fg },
  }
end

function theme.telescope()
  -- local bg = '#0f0c19'
  local bgfaded = '#110f1b'
  local bgfaded2 = '#1a1824'
  local accent = '#4e3aA3'

  updateScheme {
    TelescopeNormal = { bg = bgfaded },
    TelescopeBorder = { bg = bgfaded, fg = bgfaded },
    TelescopePreviewNormal = { bg = bgfaded },
    TelescopePreviewTitle = { bg = accent, fg = '#ffffff' },
    TelescopeResultsTitle = { bg = bgfaded, fg = bgfaded },
    TelescopePromptNormal = { bg = bgfaded2 },
    TelescopePromptTitle = { bg = accent, fg = '#ffffff' },
    TelescopePromptBorder = { bg = bgfaded2, fg = bgfaded2 },
    TelescopePromptPrefix = { bg = bgfaded2 },
  }
end

function theme.lsp()
  local lensColors = {
    Error = '#db4b4b',
    Warn = '#ffaf68',
    Info = '#d0bf78',
    Hint = '#513970',
    Lens = '#513970',
  }

  updateScheme {
    DiagnosticError = { fg = lensColors.Error },
    DiagnosticWarn = { fg = lensColors.Warn },
    DiagnosticInfo = { fg = lensColors.Info },
    DiagnosticHint = { fg = lensColors.Hint },
    DiagnosticUnderlineError = { fg = lensColors.Error },
    DiagnosticUnderlineWarn = { fg = lensColors.Warn },
    DiagnosticUnderlineInfo = { fg = lensColors.Info },
    DiagnosticUnderlineHint = { fg = lensColors.Hint },
    LspCodeLens = { fg = lensColors.Lens },
    LspSignatureActiveParameter = { fg = lensColors.Info },
  }
end

function theme.lualine()
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

return theme
