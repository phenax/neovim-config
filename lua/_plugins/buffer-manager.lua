local plugin = {
  'j-morano/buffer_manager.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    {
      mode = 'n',
      '<localleader>b',
      function() require 'buffer_manager.ui'.toggle_quick_menu() end,
      noremap = true,
    },
  },
}

-- `<localleader> index` keys
for i = 0, 9 do
  local bidx = i
  if i == 0 then bidx = 10 end
  table.insert(plugin.keys, {
    mode = 'n',
    '<localleader>' .. i,
    function() require 'buffer_manager.ui'.nav_file(bidx) end,
    noremap = true,
    silent = true,
  })
end

local M = {
  bf_git_ns = vim.api.nvim_create_namespace 'buffer_manager/git',
  enable_git_indicators = true,
  bf_file_ns = vim.api.nvim_create_namespace 'buffer_manager/file',
  enable_file_indicators = true,
}

function plugin.config()
  require('buffer_manager').setup {
    select_menu_item_commands = {
      { key = '<CR>',  command = 'edit' },
      { key = 'L',     command = 'edit' },
      { key = '<C-v>', command = 'vsplit' },
      { key = '<C-h>', command = 'split' },
    },
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    width = 0.7,
    height = 0.5,
    highlight = 'Normal:BufferManagerBorder',
    win_extra_options = {
      winhighlight = 'Normal:BufferManagerNormal,LineNr:BufferManagerLineNr,Visual:BufferManagerVisual,CursorLine:BufferManagerCursorLine',
      cursorline = true,
    },
  }

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'buffer_manager' },
    callback = function(opts)
      -- Load files from git status into buffer manager
      vim.keymap.set('n', '<localleader>gg', function()
        local files = vim.tbl_map(function(st) return st[2] end, M.get_git_status())
        vim.api.nvim_buf_set_lines(opts.buf, -1, -1, false, files)
      end, { buffer = true })

      -- Show git signs for files on buffer_manager
      vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
        buffer = opts.buf,
        callback = function()
          M.show_file_hint(opts.buf)
          M.show_git_signs(opts.buf)
        end,
      })
      M.show_file_hint(opts.buf)
      M.show_git_signs(opts.buf)
    end,
  })
end

function M.show_file_hint(bufnr)
  if not M.enable_file_indicators then return end;

  vim.api.nvim_buf_clear_namespace(bufnr, M.bf_file_ns, 0, -1)

  local buf_files = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #buf_files == 0 or (#buf_files == 1 and buf_files[1] == '') then return end

  for index, file in ipairs(buf_files) do
    if file ~= '' then
      local segments = vim.split(file, '/')
      local file_short = segments[#segments]
      if #segments > 1 then
        file_short = segments[#segments - 1] .. '/' .. segments[#segments]
      end

      vim.api.nvim_buf_set_extmark(bufnr, M.bf_file_ns, index - 1, 0, {
        virt_text = { { file_short, 'BufferManagerHighlight' }, { ' | ' } },
        virt_text_pos = 'inline',
        virt_lines_above = true,
        virt_lines_leftcol = false,
      })
    end
  end
end

function M.show_git_signs(bufnr)
  if not M.enable_git_indicators then return end;

  vim.api.nvim_buf_clear_namespace(bufnr, M.bf_git_ns, 0, -1)

  local buf_files = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if #buf_files == 0 or (#buf_files == 1 and buf_files[1] == '') then return end

  local git_status = M.get_git_status()

  for index, file in ipairs(buf_files) do
    if file ~= '' then
      local matches = vim.tbl_filter(function(st) return st[2] == file end, git_status)

      for _, gs in ipairs(matches) do
        local status, _ = unpack(gs)
        vim.api.nvim_buf_set_extmark(bufnr, M.bf_git_ns, index - 1, 0, {
          virt_text = { M.get_virt_text(status) },
        })
      end
    end
  end
end

function M.get_virt_text(status)
  if status == 'M' then
    return { '~', 'BufferManagerDiffChange' }
  elseif status == 'A' or status == '?' then
    return { '+', 'BufferManagerDiffAdd' }
  elseif status == 'D' then
    return { '-', 'BufferManagerDiffDelete' }
  else
    return { '?', 'BufferManagerDiffChange' }
  end
end

function M.get_git_status()
  local ok, git_status = pcall(vim.fn.systemlist, { 'git', 'status', '--porcelain=v1' })
  if not ok then return {} end
  return vim.tbl_map(function(l)
    local status, path = l:match '(%S) (.+)'
    return { status, vim.fn.trim(path) }
  end, git_status)
end

return plugin
