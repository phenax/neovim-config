-- [nfnl] fnl/_plugins/gitgutter.fnl
local function config()
  vim.keymap.set("n", "<localleader>hh", "<Plug>(GitGutterPreviewHunk)")
  vim.keymap.set("n", "<localleader>hn", "<Plug>(GitGutterNextHunk)")
  vim.keymap.set("n", "<localleader>hp", "<Plug>(GitGutterPrevHunk)")
  vim.keymap.set("n", "<localleader>hs", "<Plug>(GitGutterStageHunk)")
  return vim.keymap.set("n", "<localleader>hu", "<Plug>(GitGutterUndoHunk)")
end
return {config = config}
