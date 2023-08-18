
-- Close buffer
vim.keymap.set({ 'n', 'i' }, '<C-d>', ':BD<CR>')

-- Delete all buffers except for the current one
vim.cmd [[ command! CloseAll :%bd|e#|bd#|'" ]]
vim.keymap.set('n', '<leader>ca', [[ :CloseAll<cr> ]])

-- Toggle between last 2 buffers
vim.keymap.set('n', '<localleader><tab>', ':b#<CR>')

-- Split window navigation
vim.keymap.set('n', '<M-h>', '<C-w>h')
vim.keymap.set('n', '<M-l>', '<C-w>l')
vim.keymap.set('n', '<M-k>', '<C-w>k')
vim.keymap.set('n', '<M-j>', '<C-w>j')

