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
    Normal = { bg = 'NONE' },
    ColorColumn = { bg = '#15121f' },
  }

  theme.telescope()
  theme.lsp()
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

return theme
