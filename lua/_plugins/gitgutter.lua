return {
  'airblade/vim-gitgutter',
  event = 'BufReadPost',
  keys = {
    { mode = 'n', '<localleader>hh', '<Plug>(GitGutterPreviewHunk)' },
    { mode = 'n', '<localleader>hn', '<Plug>(GitGutterNextHunk)' },
    { mode = 'n', '<localleader>hp', '<Plug>(GitGutterPrevHunk)' },
    { mode = 'n', '<localleader>hs', '<Plug>(GitGutterStageHunk)' },
    { mode = 'n', '<localleader>hu', '<Plug>(GitGutterUndoHunk)' },
  },
}
