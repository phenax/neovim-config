local exec = vim.api.nvim_command
local fn = vim.fn
local o = vim.o
local g = vim.g

-- TODO: Make colorscheme variable
local theme = {}

function theme.plugins(use)
  use 'phenax/palenight.vim'
  use 'ryanoasis/vim-devicons'

  use 'itchyny/lightline.vim'
  use 'mengelbrecht/lightline-bufferline'
end


function theme.initialize()
  exec [[colorscheme palenight]]

  o.background = "dark"
  g.base16colorspace = 256

  o.t_Co = "256"

  --hi Normal guibg=NONE ctermbg=NONE
  o.showtabline = 2

  -- g['$NVIM_TUI_ENABLE_TRUE_COLOR'] = 1
  if fn.has("termguicolors") then
    o.t_8f = "[[38;2;%lu;%lu;%lum"
    o.t_8b = "[[48;2;%lu;%lu;%lum"
    o.termguicolors = true
  end

  theme.lightline()
end


function theme.lightline()
  g.lightline = {
    colorscheme = "palenight",
    enable = {
      statusline = 1,
      tabline = 1,
    },
    active = {
      left = {
         { 'mode' },
         { 'gitbranch', 'readonly' },
         { 'filename', 'dir' },
      },
      right = {
         { 'lineinfo' },
         { 'total_lines' },
         { 'filetype' },
      },
    },
    component = {
      lineinfo = 'L %3l:%-2v',
      dir = '%F',
      total_lines = '[%L]',
    },
    component_function = {
      gitbranch = 'fugitive#head',
    },
    component_type = { buffers = 'tabsel' },
    tabline = { left = { {'buffers'} }, right = { {} } },
    tab = {
      active = { 'tabnum', 'filename', 'modified' },
      inactive = { 'tabnum', 'filename', 'modified' },
    },
    component_expand = {
      buffers = 'lightline#bufferline#buffers'
    }
  };

  g["lightline#bufferline#show_number"] = 2
  g["lightline#bufferline#number_separator"] = ': '
  g["lightline#bufferline#read_only"] = ' 🔒 '
  g["lightline#bufferline#modified"] = ' 🛑 '
  g["lightline#bufferline#enable_devicons"] = 1
  g["lightline#bufferline#filename_modifier"] = ':t'
end

return theme;
