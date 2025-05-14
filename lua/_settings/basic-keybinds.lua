-- Delete all buffers except for the current one
vim.cmd [[command! CloseAll :%bd|e#|bd#|'"]]

-- Case conversion on selection
vim.keymap.set('x', '<leader>cc', [[:<c-u>s#\%V[_]\+\(.\)#\U\1#g<cr>]])
vim.keymap.set('x', '<leader>cu', [[:<c-u>s#\%V[A-Z]\+#_\l\0#g<cr>]])

-- vim.keymap.set({ 'n', 'v' }, 'gh', '_')
-- vim.keymap.set({ 'n', 'v' }, 'gl', '$')

-- tab close
vim.keymap.set('n', '<leader>qq', '<cmd>tabclose<cr>')

-- Toggle between last 2 buffers
vim.keymap.set('n', '<localleader><tab>', ':b#<CR>')

-- Split window navigation
vim.keymap.set('n', '<M-h>', '<C-w>h')
vim.keymap.set('n', '<M-l>', '<C-w>l')
vim.keymap.set('n', '<M-k>', '<C-w>k')
vim.keymap.set('n', '<M-j>', '<C-w>j')

-- Disable weird ones
vim.cmd [[map q: <Nop>]]
vim.cmd [[nnoremap Q <nop>]]
vim.cmd [[nnoremap S <nop>]]

-- Manage typos
vim.cmd [[command! W :w]]
vim.cmd [[command! Q :q]]
vim.cmd [[command! Qa :qa]]

-- Preserve selection when changing indentation
vim.cmd [[xnoremap <  <gv]]
vim.cmd [[xnoremap >  >gv]]

-- Move line up and down
vim.keymap.set('v', 'K', [[:m '<-2<CR>gv=gv]], { noremap = true, silent = true })
vim.keymap.set('v', 'J', [[:m '>+1<CR>gv=gv]], { noremap = true, silent = true })

-- Save
vim.keymap.set('n', '<C-s>', '<cmd>w<cr>', { noremap = true, silent = true })

-- Clipboard
vim.keymap.set('v', '<C-c>', '"+y')

-- Force indent for any buffer
function SetIndent(indent) vim.cmd(':set shiftwidth=' .. indent .. ' expandtab') end

-- Terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Sessions
vim.keymap.set('n', '<leader>sw', ':mksession! .vim.session<cr>')
vim.keymap.set('n', '<leader>sl', ':source .vim.session<cr>')

-- No highlight
vim.keymap.set('n', '<c-\\>', ':noh<cr>')

-- Replace word
vim.keymap.set('n', '<localleader>rw', '*:%s//<c-r><c-w>')

-- Sort selection
vim.keymap.set('v', 'gs', ':sort<cr>')

-- Search in selection only
vim.keymap.set('x', 'g/', '<Esc>/\\%V')

-- go to command line window (overrides changelist navigation keybind)
vim.keymap.set('n', 'g;', ':<c-f>i')

-- Spell checker
vim.keymap.set('n', '<leader>==', ':setlocal spell! spelllang=en_us<CR>')
