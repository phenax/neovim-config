-- [nfnl] fnl/phenax/quickfix.fnl
local qf
local function _1_()
  return math.max(4, (vim.o.lines * 0.3))
end
qf = {window_size = _1_}
qf.initialize = function()
  vim.keymap.set("n", "<c-c>o", "<cmd>copen<cr>")
  local function _2_()
    vim.diagnostic.setqflist()
    return vim.cmd.copen()
  end
  vim.keymap.set("n", "<leader>xx", _2_)
  local function _3_()
    return qf.quickfix_window_setup()
  end
  return vim.api.nvim_create_autocmd("FileType", {callback = _3_, pattern = {"qf"}})
end
qf.quickfix_window_setup = function()
  vim.keymap.set("n", "q", "<cmd>cclose<cr>", {buffer = true, nowait = true})
  vim.keymap.set("n", "L", "<cmd>cnewer<cr>", {buffer = true})
  vim.keymap.set("n", "H", "<cmd>colder<cr>", {buffer = true})
  vim.keymap.set("n", "C", "<cmd>cexpr []<cr>", {buffer = true})
  return qf.set_qf_win_height()
end
qf.set_qf_win_height = function()
  local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_win_get_buf(win)
  if (vim.api.nvim_get_option_value("filetype", {buf = buf}) == "qf") then
    local h = math.floor(qf.window_size())
    return vim.api.nvim_win_set_height(win, h)
  else
    return nil
  end
end
return qf
