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

-- Convert search mode to command mode
local function enforce_cmd_mode(callback)
  local cmd_type = vim.fn.getcmdtype()
  if cmd_type == '/' or cmd_type == '?' then
    local cmd = vim.fn.getcmdline()
    local esc = vim.api.nvim_replace_termcodes('<Esc>', true, false, true)
    vim.api.nvim_feedkeys(esc, 'n', false)
    vim.schedule(function()
      vim.api.nvim_feedkeys(':' .. cmd, 'n', false)
      callback()
    end)
  else
    callback()
  end
end

-- Toggle between '<,'>s and %s
local function toggle_cmd_range()
  local cmd = vim.fn.getcmdline()
  local cmd_type = vim.fn.getcmdtype()

  if cmd:match("^'<,'>") then return cmd:gsub("^'<,'>", "%%") end
  if cmd:match("^%%") then return cmd:gsub("^%%", "'<,'>") end
  return "%" .. cmd
end

vim.keymap.set('c', '<C-i>', function()
  enforce_cmd_mode(function()
    local new_cmd = toggle_cmd_range()
    vim.fn.setcmdline(new_cmd)
  end)
end, { noremap = true })
