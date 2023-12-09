return {
  'qpkorr/vim-bufkill',
  config = function()
    vim.keymap.set({ 'n', 'i' }, '<C-d>', ':BD<CR>')
  end
}
