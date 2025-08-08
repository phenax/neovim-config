local M                = { actions = {} }
local picker_history   = require 'phenax.snacks_picker_history'
local sortable_buffers = require 'phenax.sortable_buffers'
local core             = require 'nfnl.core'

local plugin           = {
  priority = 100,
  config = function()
    require 'snacks'.setup {
      gitbrowse = { enabled = true },
      bufdelete = { enabled = true },
      quickfile = { enabled = true },
      rename = { enabled = true },
      bigfile = { enabled = true, size = 1 * 1024 * 1024 },
      words = { enabled = true, debounce = 80, modes = { 'n' } },
      picker = M.picker_config(),
      styles = {
        phenax_git_diff = {
          style = 'blame_line',
          border = 'single',
        },
        blame_line = {
          position = 'float',
          keys = {
            q = 'close',
            blame_term_quit = { 'q', function(self) self:close() end, mode = 't' },
          },
          on_win = function() vim.cmd.startinsert() end,
        },
      },
    }
  end,

  keys = core.concat(sortable_buffers.lazy_keys(), {
    { mode = 'n',          '<c-d>',            function() Snacks.bufdelete() end },
    { mode = 'n',          '<c-f>',            function() Snacks.picker.grep() end },
    { mode = 'n',          '<leader>f',        function() M.find_files() end },
    { mode = 'n',          '<leader>sp',       function() Snacks.picker.pickers() end },
    { mode = 'n',          '<C-_>',            function() Snacks.picker.grep_buffers() end },
    { mode = 'n',          '<localleader>ne',  function() Snacks.picker.explorer() end },
    { mode = 'n',          '<localleader>uu',  function() Snacks.picker.undo() end },
    { mode = 'n',          'z=',               function() Snacks.picker.spelling() end },
    { mode = 'n',          '<leader>tr',       function() Snacks.picker.resume() end },
    { mode = 'n',          '<leader>qf',       function() Snacks.picker.qflist() end },
    -- Git
    { mode = { 'n', 'v' }, '<leader>gb',       function() Snacks.gitbrowse() end },
    { mode = 'n',          '<localleader>gbb', function() Snacks.picker.git_branches() end },
    { mode = 'n',          '<localleader>gbs', function() Snacks.picker.git_stash() end },
    { mode = 'n',          '<localleader>gm',  function() Snacks.git.blame_line({ count = -1 }) end },
    -- LSP
    { mode = 'n',          'grr',              function() Snacks.picker.lsp_references() end },
    { mode = 'n',          'gd',               function() Snacks.picker.lsp_definitions() end },
    { mode = 'n',          'gt',               function() Snacks.picker.lsp_type_definitions() end },
    { mode = 'n',          '<localleader>ns',  function() Snacks.picker.lsp_symbols() end },
  }),
}

function M.picker_config()
  return {
    enabled = true,
    ui_select = true,
    prompt = ' λ ',
    icons = { files = { enabled = false } },
    layout = function()
      local show_preview = vim.o.columns >= 120
      return {
        layout = {
          box = 'vertical',
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.65,
          border = 'top',
          title = ' {title} {live} {flags}',
          title_pos = 'center',
          { win = 'input', height = 1, border = 'bottom' },
          {
            box = 'horizontal',
            { win = 'list', border = 'none' },
            (show_preview and { win = 'preview', title = '', width = 0.4, border = 'none' } or nil),
          },
        }
      }
    end,
    win = {
      input = { keys = M.picker_mappings() },
      list = { keys = M.picker_mappings() },
    },
    on_close = function(picker)
      picker_history.save_picker(picker)
    end,
  }
end

function M.picker_mappings()
  return vim.tbl_extend('force', M.select_index_keys(), {
    ['<c-p>'] = { 'toggle_preview', mode = { 'i', 'n' } },
  })
end

function M.find_files()
  if Snacks.git.get_root() then
    Snacks.picker.git_files({ untracked = true })
  else
    Snacks.picker.files()
  end
end

function M.select_index_keys()
  local keymaps = {}
  for i = 1, 10 do
    local key = i
    if i == 10 then key = 0 end
    keymaps['<M-' .. key .. '>'] = { M.actions.highlight_index(i - 1), mode = { 'i', 'n' } }
    keymaps[tostring(key)] = { M.actions.open_index(i - 1), mode = { 'n' } }
  end
  return keymaps
end

function M.actions.highlight_index(index)
  return function()
    local picker = M.current_picker()
    if not picker then return end
    picker.list:_move(index - picker.list.cursor + 1)
  end
end

function M.actions.open_index(index)
  return function()
    local picker = M.current_picker()
    if not picker then return end
    picker.list:_move(index - picker.list.cursor + 1)
    picker:action('confirm')
  end
end

function M.current_picker()
  return Snacks.picker.get()[1]
end

return plugin
