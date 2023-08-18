
-- Close buffer
vim.keymap.set({ 'n', 'i' }, '<C-d>', ':BD<CR>')

-- Delete all buffers except for the current one
vim.cmd [[command! CloseAll :%bd|e#|bd#|'"]]
vim.keymap.set('n', '<leader>ca', [[ :CloseAll<cr> ]])

-- Toggle between last 2 buffers
vim.keymap.set('n', '<localleader><tab>', ':b#<CR>')

-- Split window navigation
vim.keymap.set('n', '<M-h>', '<C-w>h')
vim.keymap.set('n', '<M-l>', '<C-w>l')
vim.keymap.set('n', '<M-k>', '<C-w>k')
vim.keymap.set('n', '<M-j>', '<C-w>j')

-- Prevent typo issues
vim.cmd [[map q: <Nop>]]
vim.cmd [[nnoremap Q <nop>]]
vim.cmd [[nnoremap S <nop>]]
vim.cmd [[command! W :w]]
vim.cmd [[command! Q :q]]
vim.cmd [[command! Qa :qa]]

-- Move line up and down
vim.keymap.set('v', 'K', [[:m '<-2<CR>gv=gv]], { noremap = true, silent = true })
vim.keymap.set('v', 'J', [[:m '>+1<CR>gv=gv]], { noremap = true, silent = true })

-- Copy file path
vim.cmd [[command! CpPath :let @+=expand("%")]]
vim.cmd [[command! CpPathAbs :let @+=expand("%:p")]]

-- Save
vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true, silent = true })

-- Clipboard
vim.keymap.set('v', '<C-c>', '"+y')

-- Force indent for any buffer
function SetIndent(indent)
  exec(":set shiftwidth=".. indent .." expandtab")
end

