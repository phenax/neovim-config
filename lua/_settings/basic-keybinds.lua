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
function SetIndent(indent) vim.cmd(':set shiftwidth=' .. indent .. ' expandtab') end

-- Terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

-- Sessions
vim.keymap.set('n', '<leader>sw', ':mksession! .vim.session<cr>')
vim.keymap.set('n', '<leader>sl', ':source .vim.session<cr>')

-- No highlight
vim.keymap.set('n', '<c-\\>', '<cmd>noh | echo fnamemodify(expand("%"), ":~:.")<cr>')

-- Replace word
vim.keymap.set('n', '<localleader>rw', '*:%s//<c-r><c-w>')

-- Code folding
vim.keymap.set('n', '<S-Tab>', 'zR')
vim.keymap.set('n', 'zx', 'zo')
vim.keymap.set('n', 'zc', 'zc')

-- Spell checker
vim.keymap.set('n', '<leader>==', ':setlocal spell! spelllang=en_us<CR>')

-- Toggle foldlevel: all or none
local function toggle_foldlevel()
  local max_level = 20
  local min_level = 1

  if vim.o.foldlevel >= max_level then
    vim.cmd [[normal! zM<CR>]]
    vim.o.foldlevel = min_level
  else
    vim.cmd [[normal! zR<CR>]]
    vim.o.foldlevel = max_level
  end
end

vim.keymap.set('n', '<leader><Tab>', toggle_foldlevel, { silent = true })

vim.keymap.set('n', '<leader>ct', function()
  if vim.o.conceallevel > 0 then
    vim.o.conceallevel = 0
  else
    vim.o.conceallevel = 2
  end
end, { silent = true, noremap = true })
