local plugin = {
  'j-morano/buffer_manager.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
}

local config = {
  bf_ns = vim.api.nvim_create_namespace('buffer_manager/git')
}

-- Key bindings
plugin.keys = {
  { mode = 'n', '<localleader>b', function() require('buffer_manager.ui').toggle_quick_menu() end, noremap = true },
}
for i = 0, 9 do
  local bidx = i
  if (i == 0) then bidx = 10 end
  table.insert(plugin.keys, {
    mode = 'n',
    '<localleader>' .. i,
    function() require('buffer_manager.ui').nav_file(bidx) end,
    noremap = true,
    silent = true,
  })
end

function plugin.config()
  require('buffer_manager').setup({
    select_menu_item_commands = {
      { key = '<CR>',  command = 'edit' },
      { key = '<C-v>', command = 'vsplit' },
      { key = '<C-h>', command = 'split' },
    },
    borderchars = { '', '', '', '', '', '', '', '' },
    width = 0.7,
    height = 0.5,
    highlight = 'Normal:BufferManagerBorder',
    win_extra_options = {
      winhighlight = 'Normal:BufferManagerNormal,LineNr:BufferManagerLineNr,Visual:BufferManagerVisual',
    },
  })

  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'buffer_manager' },
    callback = function(opts)
      -- Close all buffers except for the one under the cursor
      vim.keymap.set('n', '<leader>cr', ':v/\\%#/d<cr>', { buffer = true })

      -- Load files from git status into buffer manager
      vim.keymap.set('n', '<localleader>gg', function()
        local files = vim.tbl_map(function(st) return st[2] end, config.get_git_status())
        vim.api.nvim_buf_set_lines(opts.buf, -1, -1, false, files)
      end, { buffer = true })

      -- Show git signs for files on buffer_manager
      vim.api.nvim_create_autocmd({ 'TextChanged', 'InsertLeave' }, {
        buffer = opts.buf,
        callback = function()
          config.show_git_signs(opts.buf)
        end,
      })
      config.show_git_signs(opts.buf)
    end,
  })
end

function config.show_git_signs(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, config.bf_ns, 0, -1)

  local buf_files = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  if (#buf_files == 0 or (#buf_files == 1 and buf_files[1] == '')) then return end

  local git_status = config.get_git_status()

  for index, file in ipairs(buf_files) do
    if (file ~= '') then
      local matches = vim.tbl_filter(function(st) return st[2] == file end, git_status)

      for _, gs in ipairs(matches) do
        local status, _ = unpack(gs)
        vim.api.nvim_buf_set_extmark(bufnr, config.bf_ns, index - 1, 0, {
          virt_text = { config.get_virt_text(status) }
        })
      end
    end
  end
end

function config.get_virt_text(status)
  if (status == 'M') then
    return { '~', 'BufferManagerDiffChange' }
  elseif (status == 'A' or status == '?') then
    return { '+', 'BufferManagerDiffAdd' }
  elseif (status == 'D') then
    return { '-', 'BufferManagerDiffDelete' }
  else
    return { '?', 'BufferManagerDiffChange' }
  end
end

function config.get_git_status()
  local ok, git_status = pcall(vim.fn.systemlist, { 'git', 'status', '--porcelain=v1' })
  if not ok then return {} end
  return vim.tbl_map(
    function(l)
      local status, path = l:match('(%S) (.+)')
      return { status, vim.fn.trim(path) }
    end,
    git_status
  )
end

return plugin
