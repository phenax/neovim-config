local M = {}
local plugin = {
  keys = {
    { mode = 'n', '<localleader>gs',        '<cmd>G<cr>' },
    { mode = 'n', '<localleader>gaf',       '<cmd>G add %<cr>' },
    { mode = 'n', '<localleader>gcc',       '<cmd>G commit<cr>' },
    { mode = 'n', '<localleader>gca',       '<cmd>G commit --amend<cr>' },
    { mode = 'n', '<localleader>gpp',       '<cmd>G push<cr>' },
    { mode = 'n', '<localleader>gpu',       '<cmd>G pull<cr>' },
    { mode = 'n', '<leader>grf',            '<cmd>G reset HEAD^1 -- %<cr>' },

    -- Log
    { mode = 'n', '<localleader>glm',       '<cmd>G log --oneline HEAD...origin/master<cr>' },
    { mode = 'n', '<localleader>gl<space>', ':G log --oneline HEAD...HEAD~' },

    { mode = 'n', '<localleader>goe',       '<cmd>GFilesOpen<cr>' },
    { mode = 'n', '<localleader>gow',       '<cmd>GFilesOpen w<cr>' },

    -- Diffresult merge in left/right (Technically not fugitive but its fine)
    { mode = 'n', '<leader>gl',             '<cmd>diffget //2<cr>' },
    { mode = 'n', '<leader>gr',             '<cmd>diffget //3<cr>' },
  },

  config = function()
    local group = vim.api.nvim_create_augroup('phenax/fugitive', { clear = true })
    vim.api.nvim_create_autocmd('BufReadPost', {
      pattern = 'fugitive://*',
      group = group,
      callback = function(opts) M.setup_fugitive_buffer(opts.buf) end
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'git',
      group = group,
      callback = function(opts) M.setup_git_buffer(opts.buf) end,
    })

    vim.api.nvim_create_user_command('GFilesOpen', function(opts)
      local rev = opts.args
      if opts.args == 'w' then
        rev = vim.fn.expand('<cword>')
      end
      print('Opening files from ' .. (rev or 'last commit') .. '...')
      M.open_files_in_commit(rev)
    end, { force = true, nargs = '*' })
  end,
}

function M.setup_fugitive_buffer(buf)
  local opts = { remap = true, buffer = buf }
  vim.keymap.set('n', 'a', '-', opts)
  vim.keymap.set('n', '<Down>', ')', opts)
  vim.keymap.set('n', '<Up>', '(', opts)
  vim.keymap.set('n', '<Right>', '>', opts)
  vim.keymap.set('n', '<Left>', '<', opts)

  M.setup_git_buffer(buf)
end

function M.setup_git_buffer(buf)
  local opts = { remap = true, buffer = buf, nowait = true }
  vim.keymap.set('n', 'q', 'gq', opts)
  vim.keymap.set('n', 'gd', M.diffview_for_commit_or_file_under_cursor, opts)
  vim.keymap.set('n', 'fl', M.files_for_commit_under_cursor, opts)
  vim.api.nvim_set_option_value('bufhidden', 'delete', { buf = buf })
  vim.api.nvim_set_option_value('buflisted', false, { buf = buf })
end

function M.files_for_commit_under_cursor()
  local rev = vim.fn.expand('<cword>')
  vim.cmd.Git('show --name-only ' .. rev)
end

-- If buffer starts with `commit <rev>`, diff file under cursor
-- Else  diff commit under cursor
function M.diffview_for_commit_or_file_under_cursor()
  local buf = vim.api.nvim_get_current_buf()
  local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]

  local file, rev
  if string.match(first_line, '^commit%s+') then
    rev = first_line.gsub(first_line, '^commit%s+', '')
    file = vim.fn.expand('<cfile>')
  else
    rev = vim.fn.expand('<cword>')
  end

  M.show_diff_in_term(rev, file)
end

local current_term = nil
function M.show_diff_in_term(rev, file)
  if current_term then current_term:close() end
  local cmd = { 'git', 'show', rev }
  if file and string.len(file) > 0 then
    cmd = vim.list_extend(cmd, { '--', file })
  end
  current_term = Snacks.terminal.open(cmd, {
    interactive = false,
    win = { style = 'phenax_git_diff' },
  })
end

function M.open_files_in_commit(rev)
  local git_command = { 'git', '--no-pager', 'show', '--name-only', '--pretty=' }
  if rev and #rev > 0 then table.insert(git_command, rev) end

  local result = vim.system(git_command, {}):wait()

  if result.code ~= 0 then
    print('Exited with ' .. result.code .. ': ' .. (result.stderr or 'error'))
  end
  if string.len(result.stdout) == 0 then return end
  for fileName in string.gmatch(result.stdout, "[^\n]+") do
    vim.cmd.edit(fileName)
  end
end

return plugin

-- gu: go to untracked changes
-- gU: go to unstaged changes
-- gs: go to staged changes

-- rr: rebase continue
-- ri: interactive on commit
-- ra: rebase abort
-- ru: rebase against upstream
-- re: edit rebase todo list
-- rm: directly go to edit commit under cursor
--
-- cc: commit
-- ca: commit amend
-- P: Push commit upstream
--
-- ) and (: goto next item in status
-- X: reset file
-- dv: diff vert
-- dq: quit diff
-- gO: open file vert split
