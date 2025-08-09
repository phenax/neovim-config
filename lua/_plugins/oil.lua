-- [nfnl] fnl/_plugins/oil.fnl
local oil = require("oil")
local core = require("nfnl.core")
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local m = {}
local plugin
local function _2_()
  return m.setup()
end
plugin = {config = _2_}
local oil_keys
local function _3_()
  return m.copy_path({absolute = true})
end
local function _4_()
  vim.bo.buflisted = not vim.bo.buflisted
  return nil
end
local function _5_()
  require("oil.util").send_to_quickfix({action = "r", target = "quickfix"})
  return vim.cmd.copen()
end
local function _6_()
  return m.copy_path({absolute = false})
end
oil_keys = {["<C-p>"] = {"actions.preview", mode = "n"}, ["<C-y>"] = {_3_, mode = "n"}, ["<CR>"] = {"actions.select", mode = {"n", "v"}}, ["<c-d>"] = {"actions.close", mode = "n"}, ["<c-l>"] = _4_, ["<c-q>"] = {_5_, mode = "n"}, ["<c-t><c-t>"] = {"actions.open_terminal", mode = "n"}, ["<localleader>:"] = {"actions.open_cmdline", mode = "n", opts = {shorten_path = false}}, H = {"actions.parent", mode = "n"}, J = {"j", remap = true}, K = {"k", remap = true}, L = {"actions.select", mode = "n"}, R = {"actions.refresh", mode = "n"}, Y = {_6_, mode = "n"}, cd = {"actions.cd", mode = "n"}, ["g?"] = {"actions.show_help", mode = "n"}, gs = {"actions.change_sort", mode = "n"}, gx = {"actions.open_external", mode = "n"}, ["~"] = {"actions.open_cwd", mode = "n"}}
m.setup = function()
  vim.keymap.set("n", "<localleader>nn", "<cmd>Oil<cr>")
  local function _7_(name)
    return (name == "..")
  end
  return oil.setup({buf_options = {bufhidden = "hide", buflisted = false}, columns = {"permissions", "type", "size"}, constrain_cursor = "name", default_file_explorer = true, keymaps = oil_keys, lsp_file_methods = {enabled = true}, view_options = {case_insensitive = true, is_always_hidden = _7_, show_hidden = true}, win_options = {winbar = "%!v:lua._OilWinbarSegment()"}, delete_to_trash = false, use_default_keymaps = false})
end
m.get_cursor_path = function()
  local fname = oil.get_cursor_entry().parsed_name
  return vim.fs.joinpath(oil.get_current_dir(), fname)
end
m.copy_path = function(opts)
  local modify
  if (opts and opts.absolute) then
    modify = ":p"
  else
    modify = ":~:."
  end
  local path = vim.fn.fnamemodify(m.get_cursor_path(), modify)
  vim.fn.setreg("+", path)
  return vim.notify(("Copied to clipboard: " .. path), vim.log.levels.INFO, {title = "oil"})
end
_G._OilWinbarSegment = function()
  local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local dir = oil.get_current_dir(bufnr)
  local short_path = vim.fn.fnamemodify((dir or ""), ":~:.")
  if core["empty?"](dir) then
    return vim.api.nvim_buf_get_name(0)
  elseif present_3f(short_path) then
    return ("\226\128\166/" .. short_path)
  else
    return vim.fn.fnamemodify(dir, ":~")
  end
end
return plugin
