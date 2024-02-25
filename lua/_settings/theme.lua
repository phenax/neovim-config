local theme = {
  colors = {
    white = '#ffffff',
    slate = {
      [1] = '#0f0c19',
      [1.5] = '#130e1d',
      [2] = '#15121f',
      [3] = '#1a1824',
      [4] = '#2a2834',
      [5] = '#3e445e',
      [6] = '#7b8099',
      [7] = '#bbc0d9',
    },
    violet = {
      [1] = '#4e3aA3',
      [2] = '#513970',
      [3] = '#8e7ae3',
    },
    green = {
      [1] = '#d0bf78',
      [2] = '#51E980',
    },
    yellow = {
      [1] = '#ffaf68',
    },
    red = {
      [1] = '#ff5370',
      [2] = '#db4b4b',
      [3] = '#d63031',
      [4] = '#7c162e',
    },
    blue = {
      [1] = '#82aaff',
    },
  },
}
theme.colors.accent = theme.colors.violet[1]
theme.colors.bg = { theme.colors.slate[1], theme.colors.slate[2] }

function theme.setup(colorscheme)
  vim.o.background = 'dark'
  vim.g.base16colorspace = 256

  if vim.fn.has 'termguicolors' then
    vim.go.t_8f = '[[38;2;%lu;%lu;%lum'
    vim.go.t_8b = '[[48;2;%lu;%lu;%lum'
    vim.go.termguicolors = true
  end

  vim.cmd('colorscheme ' .. colorscheme)

  theme.update_hl {
    Normal = { bg = 'none', fg = theme.colors.slate[7] },
    NormalFloat = { bg = theme.colors.slate[3], fg = theme.colors.white },
    ColorColumn = { bg = theme.colors.slate[1.5] },
    CursorColumn = { bg = theme.colors.slate[1.5] },
    CursorLine = { bg = theme.colors.slate[1.5] },
    Whitespace = { fg = theme.colors.slate[4] },
    SignColumn = { bg = 'none' },
    StatusLine = { bg = 'none', fg = theme.colors.accent },
    StatusLineNC = { bg = 'none', fg = theme.colors.slate[5] },
    VertSplit = { bg = 'none', fg = theme.colors.slate[5] },
  }

  theme.telescope()
  theme.buffer_manager()
  theme.lsp()
  theme.neorg()
  theme.indent_blankline()
  theme.mini_files()
  theme.terminal_colors()
  theme.incline()
end

function theme.update_hl(schemes)
  for k, v in pairs(schemes) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

function theme.buffer_manager()
  local c = theme.colors
  theme.update_hl {
    BufferManagerModified = { fg = c.accent },
    BufferManagerNormal = { bg = c.slate[3], fg = c.slate[6] },
    BufferManagerBorder = { bg = c.slate[3], fg = c.slate[3] },
    BufferManagerLineNr = { bg = c.slate[3], fg = c.white },
    BufferManagerVisual = { bg = c.slate[4], fg = c.white },
    BufferManagerDiffChange = { fg = c.yellow[1], bold = true },
    BufferManagerDiffAdd = { fg = c.green[2], bold = true },
    BufferManagerDiffDelete = { fg = c.red[2], bold = true },
  }
end

function theme.telescope()
  local c = theme.colors
  theme.update_hl {
    TelescopeNormal = { bg = c.bg[2] },
    TelescopeBorder = { bg = c.bg[2], fg = c.bg[2] },
    TelescopePreviewNormal = { bg = c.bg[2] },
    TelescopePreviewTitle = { bg = c.accent, fg = theme.colors.white },
    TelescopeResultsTitle = { bg = c.bg[2], fg = c.bg[2] },
    TelescopePromptNormal = { bg = c.slate[3] },
    TelescopePromptTitle = { bg = c.accent, fg = theme.colors.white },
    TelescopePromptBorder = { bg = c.slate[3], fg = c.slate[3] },
    TelescopePromptPrefix = { bg = c.slate[3] },
  }
end

function theme.lsp()
  local lensColors = {
    Error = theme.colors.red[2],
    Warn = theme.colors.yellow[1],
    Info = theme.colors.green[1],
    Hint = theme.colors.violet[2],
    Lens = theme.colors.violet[2],
  }

  theme.update_hl {
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

function theme.get_lualine_theme()
  local colors = theme.colors

  local thm = require 'lualine.themes.iceberg_dark'

  thm.normal.a = { bg = colors.accent, fg = colors.white, gui = 'bold' }
  thm.inactive.a = { bg = colors.bg[2], fg = colors.slate[6] }

  local bline = { bg = colors.bg[2], fg = colors.slate[7], gui = 'bold' }
  thm.normal.b = bline
  thm.insert.b = bline
  thm.visual.b = bline
  thm.replace.b = bline
  thm.inactive.b = bline

  local cline = { bg = colors.bg[1], fg = colors.slate[6] }
  thm.normal.c = cline
  thm.insert.c = cline
  thm.visual.c = cline
  thm.replace.c = cline
  thm.inactive.c = cline

  return thm
end

function theme.neorg()
  theme.update_hl {
    -- Color for text
    ['@neorg.markup.bold'] = { fg = theme.colors.green[2], bold = true },
    ['@neorg.markup.italic'] = { fg = theme.colors.yellow[1] },
    ['@neorg.markup.underline'] = { fg = theme.colors.red[1], underline = true },
    -- Links
    ['@neorg.anchors.declaration'] = { fg = theme.colors.violet[3] },
    ['@neorg.links.description.norg'] = { fg = theme.colors.violet[3] },
    ['@neorg.links.location.url.norg'] = { fg = theme.colors.blue[1], underline = true },
    ['@neorg.todo_items.pending.norg'] = { fg = theme.colors.yellow[1] },
    ['@neorg.todo_items.urgent.norg'] = { fg = theme.colors.red[1], bold = true },
    -- Code highlights
    ['@neorg.tags.ranged_verbatim.code_block'] = { bg = theme.colors.slate[3] },
    ['@neorg.markup.verbatim'] = { bg = theme.colors.slate[3] },
  }
end

function theme.indent_blankline()
  theme.update_hl {
    IndentBlanklineChar = { fg = theme.colors.slate[3], nocombine = true },
    IndentBlanklineSpaceChar = { fg = theme.colors.slate[3], nocombine = true },
    IndentBlanklineContextStart = { fg = theme.colors.slate[3], nocombine = true },
    IndentBlanklineContextChar = { fg = theme.colors.slate[3], nocombine = true },
  }
end

function theme.mini_files()
  local c = theme.colors
  theme.update_hl {
    MiniFilesBorder = { bg = c.slate[3], fg = c.slate[3] },
    MiniFilesBorderModified = { bg = c.accent, fg = c.accent },
    MiniFilesNormal = { bg = c.slate[3], fg = c.slate[6] },
    MiniFilesTitle = { fg = c.white, bg = c.slate[3], bold = true },
    MiniFilesTitleFocused = { fg = c.white, bg = c.accent, bold = true },
    MiniFilesCursorLine = { bg = c.slate[2], bold = true },
  }
end

function theme.terminal_colors()
  vim.g.terminal_color_0 = theme.colors.slate[2]
  vim.g.terminal_color_1 = '#e06c75'
  vim.g.terminal_color_10 = '#a3be8c'
  vim.g.terminal_color_11 = '#f7b731'
  vim.g.terminal_color_12 = '#5e81ac'
  vim.g.terminal_color_13 = '#4e3aA3'
  vim.g.terminal_color_14 = '#0fb9b1'
  vim.g.terminal_color_15 = '#ebdbb2'
  vim.g.terminal_color_2 = '#98C379'
  vim.g.terminal_color_3 = '#E5C07B'
  vim.g.terminal_color_4 = '#60a3bc'
  vim.g.terminal_color_5 = '#4e3aA3'
  vim.g.terminal_color_6 = '#56B6C2'
  vim.g.terminal_color_7 = '#ABB2BF'
  vim.g.terminal_color_8 = '#555555'
  vim.g.terminal_color_9 = '#7c162e'
end

function theme.incline()
  local c = theme.colors
  theme.update_hl {
    InclineModeNormal = { bg = c.accent, fg = c.white },
    InclineModeInactive = { bg = c.slate[3], fg = c.slate[6] },
  }
end

return theme
