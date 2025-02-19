local M = {}
local plugin = {
  'tpope/vim-fugitive',
  keys = {
    { mode = 'n', '<localleader>gs',  '<cmd>G<cr>' },
    { mode = 'n', '<localleader>gaf', '<cmd>Git add %<cr>' },
    { mode = 'n', '<localleader>gcc', '<cmd>Git commit<cr>' },
    { mode = 'n', '<localleader>gca', '<cmd>Git commit --amend<cr>' },
    { mode = 'n', '<localleader>gpp', '<cmd>Git push<cr>' },
    { mode = 'n', '<localleader>gpu', '<cmd>Git pull<cr>' },
    { mode = 'n', '<localleader>gl',  '<cmd>Git log<cr>' },
    { mode = 'n', '<localleader>goe', '<cmd>GFiles<cr>' },
    { mode = 'n', '<localleader>gow', '<cmd>GFiles w<cr>' },

    -- Diffresult merge in left/right (Technically not fugitive but its fine)
    { mode = 'n', '<leader>gl',       '<cmd>diffget //2<cr>' },
    { mode = 'n', '<leader>gr',       '<cmd>diffget //3<cr>' },
  },
  cmd = { 'Git', 'G', 'GFiles' },
  config = function()
    vim.cmd [[ autocmd BufReadPost fugitive://* set bufhidden=delete ]]

    vim.api.nvim_create_user_command('GFiles', function(opts)
      local rev = opts.args
      if opts.args == "w" then
        rev = vim.fn.expand("<cword>")
      end
      print('Opening ' .. rev)
      M.openFilesInCommit(rev)
    end, { force = true, nargs = '*' })
  end,
}

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
-- a: stage/unstage
-- dv: diff vert
-- dq: quit diff
-- gO: open file vert split

function M.openFilesInCommit(rev)
  local git_command = { 'git', '--no-pager', 'show', '--name-only', '--pretty=' }
  if rev and #rev > 0 then table.insert(git_command, rev) end

  local result = vim.system(git_command, {}):wait()

  if result.code ~= 0 then
    print('Exited with ' .. result.code .. ': ' .. (result.stderr or 'error'))
  end
  if #result.stdout == 0 then return end
  for fileName in string.gmatch(result.stdout, "[^\n]+") do
    vim.cmd.edit(fileName)
  end
end

return plugin
