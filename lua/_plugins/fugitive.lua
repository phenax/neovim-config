-- [nfnl] fnl/_plugins/fugitive.fnl
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local plugin = {}
local m = {}
plugin.config = function()
  local group = vim.api.nvim_create_augroup("phenax/fugitive", {clear = true})
  local function _2_(opts)
    return m.setup_fugitive_buffer(opts.buf)
  end
  vim.api.nvim_create_autocmd("BufReadPost", {group = group, pattern = "fugitive://*", callback = _2_})
  local function _3_(opts)
    return m.setup_git_buffer(opts.buf)
  end
  vim.api.nvim_create_autocmd("FileType", {group = group, pattern = "git", callback = _3_})
  local function _4_(opts)
    return m.open_file_command(opts)
  end
  vim.api.nvim_create_user_command("GFilesOpen", _4_, {force = true, nargs = "*"})
  vim.keymap.set("n", "<localleader>gs", "<cmd>G<cr>")
  vim.keymap.set("n", "<localleader>gaf", "<cmd>G add %<cr>")
  vim.keymap.set("n", "<localleader>gcc", "<cmd>G commit<cr>")
  vim.keymap.set("n", "<localleader>gca", "<cmd>G commit --amend<cr>")
  vim.keymap.set("n", "<localleader>gpp", "<cmd>G push<cr>")
  vim.keymap.set("n", "<localleader>gpu", "<cmd>G pull<cr>")
  vim.keymap.set("n", "<leader>grf", "<cmd>G reset HEAD^1 -- %<cr>")
  vim.keymap.set("n", "<localleader>glm", "<cmd>G log --oneline HEAD...origin/master<cr>")
  vim.keymap.set("n", "<localleader>gl<space>", ":G log --oneline HEAD...HEAD~")
  vim.keymap.set("n", "<localleader>goe", "<cmd>GFilesOpen<cr>")
  vim.keymap.set("n", "<localleader>gow", "<cmd>GFilesOpen w<cr>")
  vim.keymap.set("n", "<leader>gl", "<cmd>diffget //2<cr>")
  return vim.keymap.set("n", "<leader>gr", "<cmd>diffget //3<cr>")
end
m.open_file_command = function(opts)
  local rev
  if (opts.args == "w") then
    rev = vim.fn.expand("<cword>")
  else
    rev = opts.args
  end
  print(("Opening files from " .. (rev or "last commit") .. "..."))
  return m.open_files_in_commit(rev)
end
m.setup_fugitive_buffer = function(buf)
  local opts = {buffer = buf, remap = true}
  vim.keymap.set("n", "a", "-", opts)
  vim.keymap.set("n", "<Down>", ")", opts)
  vim.keymap.set("n", "<Up>", "(", opts)
  vim.keymap.set("n", "<Right>", ">", opts)
  vim.keymap.set("n", "<Left>", "<", opts)
  return m.setup_git_buffer(buf)
end
m.setup_git_buffer = function(buf)
  local opts = {buffer = buf, nowait = true, remap = true}
  vim.keymap.set("n", "q", "gq", opts)
  vim.keymap.set("n", "gd", m.diffview_for_commit_or_file_under_cursor, opts)
  vim.keymap.set("n", "fl", m.files_for_commit_under_cursor, opts)
  vim.api.nvim_set_option_value("bufhidden", "delete", {buf = buf})
  return vim.api.nvim_set_option_value("buflisted", false, {buf = buf})
end
m.files_for_commit_under_cursor = function()
  local rev = vim.fn.expand("<cword>")
  return vim.cmd.Git(("show --name-only " .. rev))
end
m.diffview_for_commit_or_file_under_cursor = function()
  local buf = vim.api.nvim_get_current_buf()
  local first_line = vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1]
  local rev, file = nil, nil
  if string.match(first_line, "^commit%s+") then
    local rev0 = first_line.gsub(first_line, "^commit%s+", "")
    local file0 = vim.fn.expand("<cfile>")
    rev, file = rev0, file0
  else
    local rev0 = vim.fn.expand("<cword>")
    rev, file = rev0, nil
  end
  return m.show_diff_in_term(rev, file)
end
local current_term = nil
m.show_diff_in_term = function(rev, _3ffile)
  if current_term then
    current_term:close()
  else
  end
  local cmd
  if present_3f(_3ffile) then
    cmd = {"git", "show", rev, "--", _3ffile}
  else
    cmd = {"git", "show", rev}
  end
  current_term = Snacks.terminal.open(cmd, {win = {style = "phenax_git_diff"}, interactive = false})
  return nil
end
m.open_files_in_commit = function(rev)
  local git_command = {"git", "--no-pager", "show", "--name-only", "--pretty="}
  if present_3f(rev) then
    table.insert(git_command, rev)
  else
  end
  local result = vim.system(git_command, {}):wait()
  if (result.code ~= 0) then
    print(("Exited with " .. result.code .. ": " .. (result.stderr or "error")))
  else
  end
  if present_3f(result.stdout) then
    for file_name in string.gmatch(result.stdout, "[^\n]+") do
      vim.cmd.edit(file_name)
    end
    return nil
  else
    return nil
  end
end
return plugin
