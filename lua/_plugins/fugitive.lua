return {
  'tpope/vim-fugitive',
  keys = {
    { mode = 'n', '<localleader>gs', '<cmd>G<cr>' },
    { mode = 'n', '<localleader>gaf', '<cmd>Git add %<cr>' },
    { mode = 'n', '<localleader>gcc', '<cmd>Git commit<cr>' },
    { mode = 'n', '<localleader>gca', '<cmd>Git commit --amend<cr>' },
    { mode = 'n', '<localleader>gpp', '<cmd>Git push<cr>' },
    { mode = 'n', '<localleader>gpu', '<cmd>Git pull<cr>' },

    -- Diffresult merge in left/right (Technically not fugitive but its fine)
    { mode = 'n', '<leader>gl', '<cmd>diffget //2<cr>' },
    { mode = 'n', '<leader>gr', '<cmd>diffget //3<cr>' },
  },
  cmd = { 'Git', 'G' },
}
