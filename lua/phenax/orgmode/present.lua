-- [nfnl] fnl/phenax/orgmode/present.fnl
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local present
local function _2_(h)
  if (h <= 15) then
    return (h * 0.8)
  else
    return (h * 0.7)
  end
end
local function _4_(w)
  if (w <= 100) then
    return (w * 0.8)
  else
    return (w * 0.6)
  end
end
present = {buffer = nil, config = {height = _2_, width = _4_}, content_buffer = nil, group = nil, namespace_id = vim.api.nvim_create_namespace("phenax/orgmodepresent"), state = {current_slide = 1, slides = {{}}}, window = nil}
local empty_buffer = nil
local background = nil
local Slide = {}
Slide.new = function(self, o)
  setmetatable(o, self)
  self.__index = self
  return o
end
Slide.get_lines = function(self)
  return self.lines
end
present.initialize = function(config)
  present.config = vim.tbl_extend("force", present.config, (config or {}))
  vim.api.nvim_set_hl(present.namespace_id, "NormalFloat", {bg = "none", fg = "#ffffff"})
  vim.api.nvim_set_hl(present.namespace_id, "NormalNC", {bg = "none", fg = "#ffffff"})
  vim.api.nvim_set_hl(present.namespace_id, "Title", {bg = "#4e3aA3", bold = true, fg = "#ffffff"})
  vim.api.nvim_set_hl(present.namespace_id, "@org.custom.block.language", {fg = "#4e3aA3"})
  return present
end
present.present = function(buffer)
  if (not_nil_3f(buffer) and (buffer ~= 0)) then
    present.content_buffer = buffer
  else
    present.content_buffer = vim.api.nvim_get_current_buf()
  end
  present.state.slides = present.prepare_slides()
  present.group = vim.api.nvim_create_augroup("phenax/orgmodepresent", {clear = true})
  present.create_background()
  local slide_buf = present.create_slide_buffer()
  present.create_window(slide_buf)
  present.configure()
  local function _7_()
    return present.configure()
  end
  return vim.api.nvim_create_autocmd("WinResized", {callback = _7_, group = present.group})
end
present.get_sections = function(node)
  local sections = {}
  for _, child in ipairs(node:named_children()) do
    if (child:type() == "section") then
      table.insert(sections, child)
    else
    end
  end
  return sections
end
present.get_directives = function(root, buffer)
  local directives = {}
  for _, child in ipairs(root:named_children()) do
    if (child:type() == "body") then
      for _0, body_ch in ipairs(child:named_children()) do
        if ((body_ch:type() == "directive") and (body_ch:named_child_count() >= 2)) then
          local name = vim.treesitter.get_node_text(body_ch:named_child(0), buffer)
          local value = vim.treesitter.get_node_text(body_ch:named_child(1), buffer)
          directives[name] = value
        else
        end
      end
    else
    end
  end
  return directives
end
present.prepare_slides = function()
  local parser = vim.treesitter.get_parser(present.content_buffer, "org", {})
  local root = parser:parse()[1]:root()
  local sections = present.get_sections(root)
  local directives = present.get_directives(root, present.content_buffer)
  local function to_slide(node)
    local startr, _, endr, _0 = vim.treesitter.get_node_range(node)
    local lines = vim.api.nvim_buf_get_lines(present.content_buffer, startr, endr, false)
    return Slide:new({lines = lines, name = "--"})
  end
  local slides = vim.tbl_map(to_slide, sections)
  if directives.title then
    local intro_heading = present.figlet_block(directives.title)
    local intro = Slide:new({lines = intro_heading, name = "Intro"})
    table.insert(slides, 1, intro)
  else
  end
  local outro_heading = present.figlet_block((directives.outro or "End of presentation"))
  local outro = Slide:new({lines = outro_heading, name = "Outro"})
  table.insert(slides, outro)
  return slides
end
present.figlet_block = function(text)
  local block = present.figlet(text)
  table.insert(block, 1, "#+begin_src")
  table.insert(block, "#+end_src")
  return block
end
present.figlet = function(text)
  local w = present.config.width(vim.o.columns)
  local cmd = {"figlet", "-c", "-w", w, text}
  local result = vim.system(cmd, {}):wait()
  local lines = {}
  for line in string.gmatch(result.stdout, "[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end
present.create_slide_buffer = function()
  present.buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_option_value("filetype", "org", {buf = present.buffer})
  local opts = {buffer = present.buffer, nowait = true}
  local function _12_()
    return present.close()
  end
  vim.keymap.set("n", "q", _12_, opts)
  local function _13_()
    return present.next_slide()
  end
  vim.keymap.set("n", "n", _13_, opts)
  local function _14_()
    return present.previous_slide()
  end
  vim.keymap.set("n", "p", _14_, opts)
  return present.buffer
end
present.next_slide = function()
  return present.set_slide_index((present.state.current_slide + 1))
end
present.previous_slide = function()
  return present.set_slide_index((present.state.current_slide - 1))
end
present.set_slide_index = function(index)
  if (index <= 0) then
    return 
  else
  end
  if (index > #present.state.slides) then
    return 
  else
  end
  present.state.current_slide = index
  local slide = present.state.slides[present.state.current_slide]
  vim.api.nvim_buf_set_lines(present.buffer, 0, ( - 1), false, slide:get_lines())
  return print(("Slide: " .. present.state.current_slide .. "/" .. #present.state.slides))
end
present.create_background = function()
  empty_buffer = vim.api.nvim_create_buf(false, true)
  background = vim.api.nvim_open_win(empty_buffer, false, {col = 0, height = 1, relative = "editor", row = 0, style = "minimal", width = 1, zindex = 100, focusable = false})
  return vim.api.nvim_win_set_hl_ns(background, present.namespace_id)
end
present.create_window = function(buffer)
  present.window = vim.api.nvim_open_win(buffer, true, {col = 5, focusable = true, height = 10, relative = "editor", row = 5, style = "minimal", width = 50, zindex = 110})
  vim.api.nvim_win_set_hl_ns(present.window, present.namespace_id)
  vim.api.nvim_set_option_value("winfixbuf", true, {win = present.window})
  vim.api.nvim_set_option_value("conceallevel", 2, {win = present.window})
  vim.api.nvim_set_option_value("concealcursor", "nvc", {win = present.window})
  return vim.api.nvim_set_option_value("listchars", "", {win = present.window})
end
present.configure = function()
  present.state.slides = present.prepare_slides()
  present.set_slide_index(present.state.current_slide)
  local width = vim.o.columns
  local height = vim.o.lines
  local slide_width = math.floor(present.config.width(width))
  local slide_height = math.floor(present.config.height(height))
  vim.api.nvim_win_set_width(background, width)
  vim.api.nvim_win_set_height(background, height)
  return vim.api.nvim_win_set_config(present.window, {col = math.floor(((width - slide_width) / 2)), height = slide_height, relative = "editor", row = math.floor(((height - slide_height) / 2)), width = slide_width})
end
present.close = function()
  vim.api.nvim_clear_autocmds({group = present.group})
  vim.api.nvim_win_close(present.window, true)
  vim.api.nvim_win_close(background, true)
  vim.api.nvim_buf_delete(present.buffer, {force = true})
  return vim.api.nvim_buf_delete(empty_buffer, {force = true})
end
return present
