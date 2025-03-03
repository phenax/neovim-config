local colors = require '_settings.colors'
local theme = {
  colors = require '_settings.colors',
  highlight = {},
}

function theme.setup(colorscheme)
  vim.o.background = 'dark'
  vim.g.base16colorspace = 256
  vim.go.termguicolors = true

  vim.api.nvim_create_autocmd('ColorScheme', { callback = theme.highlight_all })
  vim.cmd.colorscheme(colorscheme)
end

function theme.highlight.ui()
  theme.update_hl {
    Normal = { bg = 'none', fg = colors.slate[700] },
    NormalNC = { bg = colors.bg[150] },
    NormalFloat = { bg = colors.bg[200], fg = colors.white },
    ColorColumn = { bg = colors.slate[200] },
    CursorColumn = { bg = colors.slate[200] },
    CursorLine = { bg = colors.slate[200] },
    Whitespace = { fg = colors.slate[400] },
    SignColumn = { bg = 'none' },
    LineNr = { bg = 'none', fg = colors.slate[500] },
    StatusLine = { bg = 'none', fg = colors.accent },
    StatusLineNC = { bg = 'none', fg = colors.slate[500] },
    VertSplit = { bg = 'none', fg = colors.slate[500] },
    WinSeparator = { bg = 'none', fg = colors.slate[500] },
    Pmenu = { bg = colors.slate[300], fg = colors.slate[600] },
    PmenuSel = { bg = colors.accent, fg = colors.white },
    FloatBorder = { fg = colors.accent },
    RulerHighlighted = { bg = 'none', fg = colors.white, bold = true },
    netrwMarkFile = { bg = colors.slate[500], fg = colors.slate[700] },
    WinBar = { bg = colors.bg[100], fg = colors.slate[600] },
    WinBarNC = { bg = colors.bg[100], fg = colors.slate[400] },
    Folded = { bg = colors.bg[300], fg = colors.slate[600] },
  }
end

function theme.highlight.code()
  theme.update_hl {
    Comment = { fg = colors.slate[500] },
    Function = { fg = colors.blue[100] },
    Special = { fg = colors.blue[300] },
    Constant = { link = 'String' },
    Keyword = { fg = colors.violet[300] },
    Statement = { fg = colors.violet[500] },
    Number = { fg = colors.yellow[100] },
    Type = { fg = colors.slate[700] },
    Boolean = { fg = colors.yellow[100] },
    Todo = { fg = colors.red[100], bold = true },
    ['@variable'] = { fg = colors.white },
    -- Title = { bg = colors.violet[300], fg = colors.slate[100], bold = true },
    ['@markup.heading.1.markdown'] = { bg = colors.violet[300], fg = colors.slate[100], bold = true },
    ['@markup.heading.2.markdown'] = { bg = colors.blue[300], fg = colors.slate[100], bold = true },

    Tag = { fg = colors.blue[100] },
    ['@tag.builtin'] = { fg = colors.blue[300] },
    ['@tag.attribute'] = { fg = colors.blue[200] },
    ['@variable.member'] = { fg = colors.white },

    RainbowDelimiter1 = { fg = colors.slate[800] },
    RainbowDelimiter2 = { fg = colors.violet[200] },
    RainbowDelimiter3 = { fg = colors.red[500] },
    RainbowDelimiter4 = { fg = colors.slate[600] },
    RainbowDelimiter5 = { fg = colors.blue[600] },
    RainbowDelimiter6 = { fg = colors.green[600] },
  }
end

function theme.highlight.quickfix()
  theme.update_hl {
    BqfPreviewFloat = { bg = colors.bg[100], fg = colors.slate[400] },
    BqfPreviewBorder = { bg = colors.bg[100], fg = colors.accent },
    BqfPreviewTitle = { bg = colors.accent, fg = colors.white },
  }
end

function theme.highlight.fugitive()
  theme.update_hl {
    fugitiveUntrackedHeading = { fg = colors.yellow[300], bold = true },
    fugitiveUnstagedHeading = { fg = colors.yellow[200], bold = true },
    fugitiveStagedHeading = { fg = colors.green[200], bold = true },
    fugitiveHeading = { bold = true },
    DiffAdd = { bg = colors.green[600] },
    DiffChange = { bg = colors.slate[500] },
    DiffDelete = { bg = colors.red[400] },
    DiffText = { fg = colors.green[700], bg = colors.slate[500], bold = true },
    diffAdded = { bg = colors.green[600] },
    -- diffChange = { bg = colors.slate[500] },
    diffRemoved = { bg = colors.red[400] },
  }
end

function theme.highlight.buffer_manager()
  theme.update_hl {
    BufferManagerModified = { fg = colors.yellow[300], bold = true },
    BufferManagerNormal = { bg = colors.bg[300], fg = colors.slate[600] },
    BufferManagerBorder = { bg = colors.bg[300], fg = colors.slate[300] },
    BufferManagerLineNr = { bg = colors.bg[300], fg = colors.white },
    BufferManagerVisual = { bg = colors.slate[400], fg = colors.white },
    BufferManagerDiffChange = { fg = colors.yellow[300], bold = true },
    BufferManagerDiffAdd = { fg = colors.green[200], bold = true },
    BufferManagerDiffDelete = { fg = colors.red[200], bold = true },
    BufferManagerCursorLine = { bg = colors.slate[200], fg = colors.white },
    BufferManagerHighlight = { fg = colors.violet[300], bold = true },
  }
end

function theme.highlight.telescope()
  local bg = colors.bg[100]
  theme.update_hl {
    TelescopeNormal = { bg = bg },
    TelescopeBorder = { bg = bg, fg = colors.accent },
    TelescopePreviewNormal = { bg = bg },
    TelescopePreviewTitle = { bg = colors.accent, fg = colors.white },
    TelescopeResultsTitle = { bg = bg, fg = bg },
    TelescopeResultsBorder = { bg = bg, fg = bg },
    TelescopePromptNormal = { bg = bg },
    TelescopePromptTitle = { bg = colors.accent, fg = colors.white },
    TelescopePromptPrefix = { bg = bg },
  }
end

function theme.highlight.lsp()
  local lensColors = {
    Error = colors.red[500],
    Warn = colors.yellow[300],
    Info = colors.green[100],
    Hint = colors.violet[200],
    Lens = colors.violet[200],
  }

  theme.update_hl {
    DiagnosticError = { fg = lensColors.Error },
    DiagnosticWarn = { fg = lensColors.Warn },
    DiagnosticInfo = { fg = lensColors.Info },
    DiagnosticHint = { fg = lensColors.Hint },
    DiagnosticUnderlineError = { fg = lensColors.Error, underline = true, bold = true },
    DiagnosticUnderlineWarn = { fg = lensColors.Warn, underline = true, bold = true },
    DiagnosticUnderlineInfo = { fg = lensColors.Info, underline = true, bold = true },
    DiagnosticUnderlineHint = { fg = lensColors.Hint, underline = true, bold = true },
    LspCodeLens = { fg = lensColors.Lens },
    LspSignatureActiveParameter = { fg = lensColors.Info },
    LspReferenceText = { underline = true },
    LspInlayHint = { fg = colors.slate[500] },
  }
end

function theme.highlight.neorg()
  theme.update_hl {
    -- Color for text
    ['@neorg.markup.bold'] = { fg = colors.green[200], bold = true },
    ['@markup.strong'] = { fg = colors.green[200], bold = true },
    ['@neorg.markup.italic'] = { fg = colors.yellow[300] },
    ['@neorg.markup.underline'] = { fg = colors.red[100], underline = true },
    -- Links
    ['@neorg.anchors.declaration'] = { fg = colors.violet[300] },
    ['@markup.link'] = { fg = colors.violet[300] },
    ['@neorg.links.location.timestamp.norg'] = { fg = colors.green[400] },
    ['@neorg.links.description.norg'] = { fg = colors.violet[300] },
    ['@neorg.links.location.url.norg'] = { fg = colors.blue[100], underline = true },
    ['@neorg.todo_items.pending.norg'] = { fg = colors.yellow[300] },
    ['@neorg.todo_items.urgent.norg'] = { fg = colors.red[100], bold = true },
    -- Code highlights
    ['@neorg.tags.ranged_verbatim.code_block'] = { bg = colors.slate[300] },
    ['@neorg.markup.verbatim'] = { bg = colors.slate[300] },
    ['@neorg.headings.1.title.norg'] = { bg = colors.violet[300], fg = colors.slate[100], bold = true },
    ['@neorg.headings.1.prefix.norg'] = { bg = colors.violet[300], fg = colors.slate[100], bold = true, force = true },
  }
end

function theme.highlight.mini_files()
  local bg = colors.bg[300]
  theme.update_hl {
    MiniFilesBorder = { bg = bg, fg = bg },
    MiniFilesBorderModified = { bg = colors.accent, fg = colors.accent },
    MiniFilesNormal = { bg = bg, fg = colors.slate[600] },
    MiniFilesTitle = { bg = bg, fg = colors.white, bold = true },
    MiniFilesTitleFocused = { bg = colors.accent, fg = colors.white, bold = true },
    MiniFilesCursorLine = { bg = colors.slate[200], bold = true },
  }
end

function theme.highlight.terminal_colors()
  vim.g.terminal_color_0 = colors.slate[200]
  vim.g.terminal_color_1 = '#e06c75'
  vim.g.terminal_color_2 = '#98C379'
  vim.g.terminal_color_3 = '#E5C07B'
  vim.g.terminal_color_4 = '#60a3bc'
  vim.g.terminal_color_5 = '#4e3aA3'
  vim.g.terminal_color_6 = '#56B6C2'
  vim.g.terminal_color_7 = '#ABB2BF'
  vim.g.terminal_color_8 = '#555555'
  vim.g.terminal_color_9 = '#7c162e'
  vim.g.terminal_color_10 = '#a3be8c'
  vim.g.terminal_color_11 = '#f7b731'
  vim.g.terminal_color_12 = '#5e81ac'
  vim.g.terminal_color_13 = '#4e3aA3'
  vim.g.terminal_color_14 = '#0fb9b1'
  vim.g.terminal_color_15 = '#ebdbb2'
end

function theme.highlight.incline()
  theme.update_hl {
    InclineModeNormal = { bg = colors.accent, fg = colors.white },
    InclineModeInactive = { bg = colors.bg[300], fg = colors.slate[600] },
    InclineModeInverted = { bg = colors.white, fg = colors.accent },
  }
end

function theme.highlight.orgmode()
  theme.update_hl {
    ['@org.keyword.todo'] = { fg = colors.red[200], bold = true },
    ['@org.keyword.done'] = { fg = colors.green[400] },
    ['@org.plan'] = { fg = colors.slate[600] },
    ['@org.properties'] = { fg = colors.red[100] },
    ['@org.tag'] = { fg = colors.accent },
    ['@org.timestamp.active'] = { fg = colors.accent },
    ['@org.drawer'] = { fg = colors.slate[400] },
    ['@org.agenda.scheduled'] = { fg = colors.green[500] },
    ['@org.agenda.deadline'] = { fg = colors.red[200] },
    ['@org.agenda.scheduled_past'] = { fg = colors.yellow[300] },
    ['@org.agenda.today'] = { fg = colors.green[200], bold = true, underline = true },
    ['@org.agenda.weekend'] = { fg = colors.slate[700] },
  }
end

function theme.highlight_all()
  for _, value in pairs(theme.highlight) do
    value()
  end
end

function theme.update_hl(schemes)
  for k, v in pairs(schemes) do
    vim.api.nvim_set_hl(0, k, v)
  end
end

return theme
