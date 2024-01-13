return {
  'tpope/vim-fugitive',
  keys = {
    { mode = 'n', '<localleader>gs', ':G<cr>' },
    { mode = 'n', '<localleader>gaf', ':Git add %<cr>' },
    { mode = 'n', '<localleader>gcc', ':Git commit<cr>' },
    { mode = 'n', '<localleader>gca', ':Git commit --amend<cr>' },
    { mode = 'n', '<localleader>gpp', ':Git push<cr>' },
    { mode = 'n', '<localleader>gpu', ':Git pull<cr>' },
  },
  cmd = {'Git', 'G'},
}
