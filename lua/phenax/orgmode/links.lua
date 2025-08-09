-- [nfnl] fnl/phenax/orgmode/links.fnl
local _local_1_ = require("phenax.utils.utils")
local present_3f = _local_1_["present?"]
local not_nil_3f = _local_1_["not_nil?"]
local _local_2_ = require("nfnl.core")
local nil_3f = _local_2_["nil?"]
local string_3f = _local_2_["string?"]
local orgmode = require("orgmode")
local orgmode_api = require("orgmode.api")
local orglinks = {}
orglinks.initialize = function()
  local function _3_()
    return orglinks.setup_current_buf()
  end
  return vim.api.nvim_create_autocmd("FileType", {callback = _3_, group = vim.api.nvim_create_augroup("phenax/orgmode_links", {clear = true}), pattern = "org"})
end
orglinks.setup_current_buf = function()
  local function _4_()
    return orglinks.jump_to_next_link()
  end
  vim.keymap.set("n", "<Tab>", _4_, {buffer = true})
  local function _5_()
    return orglinks.jump_to_previous_link()
  end
  vim.keymap.set("n", "<S-Tab>", _5_, {buffer = true})
  local function _6_()
    return orglinks.open_at_cursor()
  end
  vim.keymap.set("n", "<CR>", _6_, {buffer = true})
  local function _7_()
    return orglinks.execute_block_under_cursor()
  end
  vim.keymap.set("n", "<M-e>", _7_, {buffer = true})
  local function _8_()
    return orglinks.open_at_cursor_ext()
  end
  vim.keymap.set("n", "gx", _8_, {buffer = true})
  local function _9_()
    return orglinks.openAtCursorImage()
  end
  return vim.keymap.set("n", "<leader>gi", _9_, {buffer = true})
end
orglinks.open_at_cursor_ext = function()
  local cursor_link = orglinks.link_under_cursor()
  if (cursor_link and cursor_link.url) then
    local full_path = (cursor_link.url:get_real_path() or cursor_link.url:get_file_path())
    if present_3f(full_path) then
      return vim.ui.open(full_path)
    else
      return nil
    end
  else
    return nil
  end
end
orglinks["command_link?"] = function(link)
  return (link and link.url and not_nil_3f(link.url.url:find("^+")))
end
orglinks.run_command_link = function(link)
  local cmd = link.url.url:sub(2)
  print(("Running: " .. cmd))
  vim.cmd(cmd)
  return vim.cmd(cmd)
end
orglinks.open_at_cursor = function()
  local link = orglinks.link_under_cursor()
  if orglinks["command_link?"](link) then
    return orglinks.run_command_link(link)
  else
    return orgmode.action("org_mappings.open_at_point")
  end
end
orglinks.jump_to_next_link = function()
  return orglinks.jump_to_link(orglinks.next_link)
end
orglinks.jump_to_previous_link = function()
  return orglinks.jump_to_link(orglinks.previous_link)
end
orglinks.next_link = function(links, cursor)
  local links_before_cursor
  local function _13_(link)
    local rowdist = (link.range.start_line - cursor[1])
    local coldist = (link.range.start_col - cursor[2])
    return ((rowdist > 0) or ((rowdist == 0) and (coldist > 0)))
  end
  links_before_cursor = vim.tbl_filter(_13_, links)
  return orglinks.get_closest_link_to_cursor(links_before_cursor, cursor)
end
orglinks.previous_link = function(links, cursor)
  local links_before_cursor
  local function _14_(link)
    local rowdist = (link.range.start_line - cursor[1])
    local coldist = (link.range.start_col - cursor[2])
    return ((rowdist < 0) or ((rowdist == 0) and (coldist < 0)))
  end
  links_before_cursor = vim.tbl_filter(_14_, links)
  return orglinks.get_closest_link_to_cursor(links_before_cursor, cursor)
end
orglinks.jump_to_link = function(get_link)
  local links = orglinks.get_doc_links()
  local win_id = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win_id)
  local link = get_link(links, cursor)
  if not_nil_3f(link) then
    return vim.api.nvim_win_set_cursor(win_id, {link.range.start_line, link.range.start_col})
  else
    return nil
  end
end
orglinks.execute_block_under_cursor = function()
  local blocks = orgmode_api:current()._file:get_blocks()
  for _, block in ipairs(blocks) do
    local start_row, _0, end_row, _1 = block.node:range(false)
    local row = vim.api.nvim_win_get_cursor(0)[1]
    if ((start_row <= row) and (end_row >= row)) then
      local lang = (block:get_language() or "lua")
      local eval = orglinks.evaluator[lang]
      if nil_3f(eval) then
        error(("No evaluator for " .. lang))
      else
      end
      local code = table.concat(block:get_content(), "\n")
      local function _17_(d)
        return print(d)
      end
      eval(code, _17_)
    else
    end
  end
  return nil
end
local function clean_output(cb)
  local function _19_(_, data)
    if not_nil_3f(data) then
    else
      string_3f(data)
    end
    cb(data:gsub("%s+$", ""))
    return cb(data)
  end
  return _19_
end
local function _21_(code, on_result)
  return vim.system({"bash", "-c", code}, {stderr = clean_output(on_result), stdout = clean_output(on_result), text = true})
end
local function _22_(code, on_result)
  return vim.system({"node", "-e", code}, {stderr = clean_output(on_result), stdout = clean_output(on_result), text = true})
end
local function _23_(code, on_result)
  return on_result(load(code)())
end
orglinks.evaluator = {bash = _21_, javascript = _22_, lua = _23_}
orglinks.link_under_cursor = function()
  local links = orglinks.get_doc_links()
  if not_nil_3f(links[1]) then
    return links[1]:at_cursor()
  else
    return nil
  end
end
orglinks.get_doc_links = function()
  local file = orgmode_api.current()
  return file._file:get_links()
end
orglinks.get_closest_link_to_cursor = function(links, cursor)
  local closest_dist = math.huge
  local closest_link = nil
  for _, link in ipairs(links) do
    local distance = orglinks.cursor_distance({link.range.start_line, link.range.start_col}, cursor)
    if (distance < closest_dist) then
      closest_dist = distance
      closest_link = link
    else
    end
  end
  return closest_link
end
orglinks.cursor_distance = function(a, b)
  if (a[1] == b[1]) then
    local ___antifnl_rtns_1___ = {math.abs((b[2] - a[2]))}
    return (table.unpack or _G.unpack)(___antifnl_rtns_1___)
  else
  end
  return (2 * math.abs((b[1] - a[1])))
end
_G._OpenImage = function(path)
  return vim.cmd(("!feh -x -F --image-bg \"#0f0c19\" " .. path))
end
return orglinks
