local M = {}
local plugin = {
  'stevearc/oil.nvim',
  dependencies = { { 'echasnovski/mini.icons', opts = {} } },
  lazy = false,
  config = function() M.setup() end,
  keys = {
    { mode = 'n', '<localleader>nn', '<cmd>Oil<cr>' },
  }
}

M.keys = {
  ['g?'] = { 'actions.show_help', mode = 'n' },

  ['H'] = { 'actions.parent', mode = 'n' },
  ['L'] = { 'actions.select', mode = 'n' },
  ['<c-o>'] = { 'actions.select', opts = { close = false }, mode = 'n' },
  ['<CR>'] = { 'actions.select', mode = 'n' },
  ['J'] = { 'j', remap = true },
  ['K'] = { 'k', remap = true },

  ['<C-v>'] = { 'actions.select', opts = { vertical = true }, mode = 'n' },
  ['<C-h>'] = { 'actions.select', opts = { horizontal = true }, mode = 'n' },

  ['<C-p>'] = { 'actions.preview', mode = 'n' },
  ['<C-c>'] = { 'actions.close', mode = 'n' },
  ['R'] = { 'actions.refresh', mode = 'n' },

  ['<localleader>q'] = { 'actions.close', mode = 'n' },
  ['<c-q>'] = {
    function()
      require 'oil.util'.send_to_quickfix({ target = 'quickfix', action = 'r' })
      vim.cmd.copen()
    end,
    mode = 'n'
  },
  ['~'] = { 'actions.open_cwd', mode = 'n' },
  ['cd'] = { 'actions.cd', mode = 'n' },
  ['gs'] = { 'actions.change_sort', mode = 'n' },
  ['gx'] = { 'actions.open_external', mode = 'n' },
  ['<localleader>:'] = { 'actions.open_cmdline', mode = 'n' },
  ['<c-t><c-t>'] = { 'actions.open_terminal', mode = 'n' },

  -- Copy path to clipboard (absolute)
  ['<C-y>'] = function()
    local path = vim.fn.fnamemodify(M.getCursorPath(), ':p')
    M.copyText(path)
  end,
  -- Copy path to clipboard (relative)
  ['Y'] = function()
    local path = vim.fn.fnamemodify(M.getCursorPath(), ':~:.')
    M.copyText(path)
  end,

  -- Telescope grep inside dir
  ['<leader><C-f>'] = function()
    local path = M.getCurrentDir()
    require('telescope.builtin').live_grep { search_dirs = { path }, prompt_title = 'Grep: ' .. path }
  end,
  -- Telescope find files inside dir
  ['<leader><leader>f'] = function()
    local path = M.getCurrentDir()
    require('telescope.builtin').find_files { search_dirs = { path }, prompt_title = 'Find: ' .. path }
  end,
}

function M.setup()
  require 'oil'.setup {
    default_file_explorer = true,
    columns = { 'icon', 'permissions', 'type', 'size' },
    lsp_file_methods = { enabled = true },
    constrain_cursor = 'name',
    delete_to_trash = false,
    view_options = {
      show_hidden = true,
      case_insensitive = true,
      is_always_hidden = function(name) return name == '..' end,
    },
    buf_options = {
      buflisted = false,
      bufhidden = 'hide',
    },
    win_options = {
      winbar = '%!v:lua._OilWinbarSegment()',
    },
    use_default_keymaps = false,
    keymaps = M.keys,
  }
end

function M.getCurrentDir()
  return require 'oil'.get_current_dir()
end

function M.getCursorPath()
  local fname = require 'oil'.get_cursor_entry().parsed_name
  return vim.fs.joinpath(M.getCurrentDir(), fname)
end

function M.copyText(text)
  vim.cmd(':let @+="' .. text .. '"')
  vim.notify('Copied to clipboard: ' .. text, vim.log.levels.INFO, { title = 'oil' })
end

function _G._OilWinbarSegment()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = require('oil').get_current_dir(bufnr)
  if dir then
    local short_path = vim.fn.fnamemodify(dir, ':~:.')
    if #short_path == 0 then return vim.fn.fnamemodify(dir, ':~') end
    return '…/' .. short_path
  else
    return vim.api.nvim_buf_get_name(0)
  end
end

return plugin
