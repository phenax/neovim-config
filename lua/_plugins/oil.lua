local M = {}
local plugin = {
  'stevearc/oil.nvim',
  lazy = false,
  config = function() M.setup() end,
  keys = {
    { mode = 'n', '<localleader>nn', '<cmd>Oil<cr>' },
  }
}

M.keys = {
  -- Navigation
  ['H'] = { 'actions.parent', mode = 'n' },
  ['L'] = { 'actions.select', mode = 'n' },
  ['J'] = { 'j', remap = true },
  ['K'] = { 'k', remap = true },
  ['~'] = { 'actions.open_cwd', mode = 'n' },

  -- Select/consume
  ['<CR>'] = { 'actions.select', mode = { 'n', 'v' } },
  ['<C-p>'] = { 'actions.preview', mode = 'n' },
  -- ['<C-S-v>'] = { 'actions.select', opts = { vertical = true }, mode = 'n' },
  -- ['<C-h>'] = { 'actions.select', opts = { horizontal = true }, mode = 'n' },
  ['gx'] = { 'actions.open_external', mode = 'n' },
  ['<localleader>:'] = { 'actions.open_cmdline', mode = 'n', opts = { shorten_path = false } },
  ['<c-t><c-t>'] = { 'actions.open_terminal', mode = 'n' },
  ['<c-q>'] = {
    function()
      require 'oil.util'.send_to_quickfix({ target = 'quickfix', action = 'r' })
      vim.cmd.copen()
    end,
    mode = 'n'
  },
  -- Copy path to clipboard
  ['<C-y>'] = { function() M.copyPath({ absolute = true }) end, mode = 'n' },
  ['Y'] = { function() M.copyPath({ absolute = false }) end, mode = 'n' },
  -- Telescope grep inside dir
  ['<leader><C-f>'] = function()
    local path = M.getCurrentDir()
    require('telescope.builtin').live_grep {
      search_dirs = { path },
      prompt_title = 'Grep: ' .. path,
    }
  end,
  -- Telescope find files inside dir
  ['<leader><leader>f'] = function()
    local path = M.getCurrentDir()
    require('telescope.builtin').find_files {
      search_dirs = { path },
      prompt_title = 'Find: ' .. path,
    }
  end,

  -- Toggle listing on oil buffer (behaves weirdly)
  ['<c-l>'] = function() vim.bo.buflisted = not vim.bo.buflisted end,

  -- Controls
  ['g?'] = { 'actions.show_help', mode = 'n' },
  ['R'] = { 'actions.refresh', mode = 'n' },
  ['<c-d>'] = { 'actions.close', mode = 'n' },
  ['cd'] = { 'actions.cd', mode = 'n' },
  ['gs'] = { 'actions.change_sort', mode = 'n' },
}

function M.setup()
  require 'oil'.setup {
    default_file_explorer = true,
    columns = { 'permissions', 'type', 'size' },
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

function M.copyPath(opts)
  local modify = ':~:.'
  if opts and opts.absolute then modify = ':p' end
  local text = vim.fn.fnamemodify(M.getCursorPath(), modify)
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
