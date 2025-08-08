-- [nfnl] fnl/_settings/theme.fnl
local colors = require("_settings.colors")
local theme = {colors = require("_settings.colors"), highlight = {}}
theme.setup = function(colorscheme)
  vim.o.background = "dark"
  vim.g.base16colorspace = 256
  vim.go.termguicolors = true
  vim.api.nvim_create_autocmd("ColorScheme", {callback = theme.highlight_all, group = vim.api.nvim_create_augroup("phenax/theme", {clear = true})})
  vim.cmd.colorscheme(colorscheme)
  return theme.setup_terminal_colors()
end
theme.highlight.ui = function()
  return theme.update_hl({ColorColumn = {bg = colors.slate[200]}, CurSearch = {bg = colors.teal[800], fg = colors.slate[300], bold = true}, CursorColumn = {bg = colors.slate[200]}, CursorLine = {bg = colors.slate[200]}, FloatBorder = {fg = colors.accent[100]}, Folded = {bg = colors.bg[300], fg = colors.slate[600]}, LineNr = {bg = "none", fg = colors.slate[500]}, Normal = {bg = "none", fg = colors.slate[700]}, NormalFloat = {bg = colors.bg[200], fg = colors.white}, NormalNC = {bg = colors.bg[150]}, Pmenu = {bg = colors.slate[300], fg = colors.slate[600]}, PmenuSel = {bg = colors.accent[100], fg = colors.white}, RulerFilePath = {bg = colors.accent[100], fg = colors.white, bold = true}, RulerFileStatus = {bg = colors.yellow[100], fg = colors.bg[100], bold = true}, RulerFileType = {bg = "none", fg = colors.white, bold = true}, Search = {bg = colors.slate[600]}, SignColumn = {bg = "none"}, StatusLine = {bg = "none", fg = colors.accent[100]}, StatusLineNC = {bg = "none", fg = colors.slate[400]}, VertSplit = {bg = "none", fg = colors.slate[400]}, Whitespace = {fg = colors.slate[400]}, WinBar = {bg = colors.bg[100], fg = colors.slate[600]}, WinBarNC = {bg = colors.bg[100], fg = colors.slate[400]}, WinSeparator = {bg = "none", fg = colors.slate[400]}, YankHighlight = {bg = colors.slate[600]}, netrwMarkFile = {bg = colors.slate[500], fg = colors.slate[700]}})
end
theme.highlight.code = function()
  return theme.update_hl({["@markup.heading.1.markdown"] = {bg = colors.accent[200], bold = true, fg = colors.slate[100]}, ["@markup.heading.2.markdown"] = {bg = colors.green[500], bold = true, fg = colors.slate[100]}, ["@markup.link"] = {fg = colors.accent[200]}, ["@markup.strong"] = {bold = true, fg = colors.green[200]}, ["@tag.attribute"] = {fg = colors.blue[200]}, ["@tag.builtin"] = {fg = colors.blue[300]}, ["@variable"] = {fg = colors.white}, ["@variable.member"] = {fg = colors.white}, Boolean = {fg = colors.pink[100]}, Comment = {fg = colors.slate[500]}, Constant = {link = "String"}, Function = {fg = colors.blue[100]}, Keyword = {fg = colors.teal[600]}, Number = {fg = colors.yellow[100]}, Special = {fg = colors.blue[300]}, Statement = {fg = colors.teal[700]}, Tag = {fg = colors.blue[100]}, Todo = {bold = true, fg = colors.red[100]}, Type = {fg = colors.slate[700]}})
end
theme.highlight.oil = function()
  return theme.update_hl({OilDir = {fg = colors.accent[200]}})
end
theme.highlight.fugitive = function()
  return theme.update_hl({DiffAdd = {bg = colors.green[600]}, DiffChange = {bg = colors.slate[500]}, DiffDelete = {bg = colors.red[400]}, DiffText = {bg = colors.slate[500], fg = colors.green[700], bold = true}, diffAdded = {bg = colors.green[600]}, diffRemoved = {bg = colors.red[400]}, fugitiveHeading = {bold = true}, fugitiveStagedHeading = {fg = colors.green[200], bold = true}, fugitiveUnstagedHeading = {fg = colors.yellow[200], bold = true}, fugitiveUntrackedHeading = {fg = colors.yellow[300], bold = true}})
end
theme.highlight.phenax_buffers = function()
  return theme.update_hl({PhenaxBufferIndex = {link = "Number"}, PhenaxBufferName = {fg = colors.slate[800]}, PhenaxBufferNameChanged = {bold = true, fg = colors.yellow[300]}, PhenaxBufferShortName = {bold = true, fg = colors.teal[800]}})
end
theme.highlight.snacks_picker = function()
  local bg = colors.bg[100]
  return theme.update_hl({SnacksPicker = {bg = bg}, SnacksPickerBorder = {bg = "none", fg = "none"}, SnacksPickerBoxTitle = {bg = colors.accent[100], fg = colors.white}, SnacksPickerCursorLine = {bg = colors.slate[500]}, SnacksPickerDir = {fg = colors.slate[650]}, SnacksPickerFile = {fg = colors.white}, SnacksPickerListCursorLine = {bg = colors.slate[500]}, SnacksPickerMatch = {fg = colors.teal[800]}, SnacksPickerPreviewCursorLine = {bg = colors.slate[500]}})
end
theme.highlight.lsp = function()
  local lens_colors = {Error = colors.red[500], Hint = colors.violet[200], Info = colors.green[100], Lens = colors.violet[200], Warn = colors.yellow[300]}
  return theme.update_hl({DiagnosticError = {fg = lens_colors.Error}, DiagnosticHint = {fg = lens_colors.Hint}, DiagnosticInfo = {fg = lens_colors.Info}, DiagnosticUnderlineError = {bold = true, fg = lens_colors.Error, underline = true}, DiagnosticUnderlineHint = {bold = true, fg = lens_colors.Hint, underline = true}, DiagnosticUnderlineInfo = {bold = true, fg = lens_colors.Info, underline = true}, DiagnosticUnderlineWarn = {bold = true, fg = lens_colors.Warn, underline = true}, DiagnosticWarn = {fg = lens_colors.Warn}, LspCodeLens = {fg = lens_colors.Lens}, LspInlayHint = {fg = colors.slate[500]}, LspReferenceText = {underline = true}, LspSignatureActiveParameter = {fg = lens_colors.Info}})
end
theme.highlight.orgmode = function()
  return theme.update_hl({["@org.agenda.deadline"] = {fg = colors.red[200]}, ["@org.agenda.scheduled"] = {fg = colors.green[500]}, ["@org.agenda.scheduled_past"] = {fg = colors.yellow[300]}, ["@org.agenda.today"] = {bold = true, fg = colors.green[200], underline = true}, ["@org.agenda.weekend"] = {fg = colors.slate[700]}, ["@org.drawer"] = {fg = colors.slate[400]}, ["@org.keyword.done"] = {fg = colors.green[400]}, ["@org.keyword.todo"] = {bold = true, fg = colors.red[200]}, ["@org.plan"] = {fg = colors.slate[600]}, ["@org.properties"] = {fg = colors.red[100]}, ["@org.tag"] = {fg = colors.accent[100]}, ["@org.timestamp.active"] = {fg = colors.accent[100]}})
end
theme.highlight_all = function()
  for _, value in pairs(theme.highlight) do
    value()
  end
  return nil
end
theme.update_hl = function(schemes)
  for k, v in pairs(schemes) do
    vim.api.nvim_set_hl(0, k, v)
  end
  return nil
end
theme.setup_terminal_colors = function()
  vim.g.terminal_color_0 = colors.slate[200]
  vim.g.terminal_color_1 = "#e06c75"
  vim.g.terminal_color_2 = "#98C379"
  vim.g.terminal_color_3 = "#E5C07B"
  vim.g.terminal_color_4 = "#60a3bc"
  vim.g.terminal_color_5 = "#4e3aA3"
  vim.g.terminal_color_6 = "#56B6C2"
  vim.g.terminal_color_7 = "#ABB2BF"
  vim.g.terminal_color_8 = "#555555"
  vim.g.terminal_color_9 = "#7c162e"
  vim.g.terminal_color_10 = "#a3be8c"
  vim.g.terminal_color_11 = "#f7b731"
  vim.g.terminal_color_12 = "#5e81ac"
  vim.g.terminal_color_13 = "#4e3aA3"
  vim.g.terminal_color_14 = "#0fb9b1"
  vim.g.terminal_color_15 = "#ebdbb2"
  return nil
end
return theme
