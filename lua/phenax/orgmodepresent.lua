local M = {
  config = {
    width = function(w)
      if w <= 100 then
        return w * 0.8
      else
        return w * 0.6
      end
    end,
    height = function(h)
      if h <= 15 then
        return h * 0.8
      else
        return h * 0.7
      end
    end,
  },
  state = {
    currentSlide = 1,
    slides = { {} },
  },
  contentBuffer = nil,
  window = nil,
  buffer = nil,
  namespace_id = vim.api.nvim_create_namespace('phenax/orgmodepresent'),
  group = nil,
}

---@type number
local empty_buffer = nil

---@type number
local background = nil

local Slide = {}

function Slide:new(o)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Slide:getName()
  return self.name
end

function Slide:getLines()
  return self.lines
end

function M.setup(config)
  M.config = vim.tbl_extend('force', M.config, config or {})

  vim.api.nvim_set_hl(M.namespace_id, 'NormalFloat', { bg = 'none', fg = '#ffffff' })
  vim.api.nvim_set_hl(M.namespace_id, 'NormalNC', { bg = 'none', fg = '#ffffff' })
  vim.api.nvim_set_hl(M.namespace_id, 'Title', { bg = '#4e3aA3', fg = '#ffffff', bold = true })
  vim.api.nvim_set_hl(M.namespace_id, '@org.custom.block.language', { fg = '#4e3aA3' })
  return M
end

---@param buffer number
function M.present(buffer)
  M.contentBuffer = vim.fn.bufnr(buffer)
  M.state.slides = M.prepareSlides()

  M.group = vim.api.nvim_create_augroup('phenax/orgmodepresent', { clear = true })
  M.createBackground()
  local slideBuf = M.createSlideBuffer()
  M.createWindow(slideBuf)

  M.configure()

  vim.api.nvim_create_autocmd('WinResized', {
    group = M.group,
    callback = function() M.configure() end,
  })
end

---@param node TSNode
function M.getSections(node)
  local sections = {}
  for _, child in ipairs(node:named_children()) do
    if child:type() == "section" then
      table.insert(sections, child)
    end
  end
  return sections
end

---@param root TSNode
---@param buffer number
function M.getDirectives(root, buffer)
  local directives = {}
  for _, child in ipairs(root:named_children()) do
    if child:type() == "body" then
      for _, bodyCh in ipairs(child:named_children()) do
        if bodyCh:type() == "directive" and bodyCh:named_child_count() >= 2 then
          ---@diagnostic disable-next-line: param-type-mismatch
          local name = vim.treesitter.get_node_text(bodyCh:named_child(0), buffer)
          ---@diagnostic disable-next-line: param-type-mismatch
          local value = vim.treesitter.get_node_text(bodyCh:named_child(1), buffer)
          directives[name] = value
        end
      end
    end
  end
  return directives
end

function M.prepareSlides()
  local parser = vim.treesitter.get_parser(M.contentBuffer, 'org', {})
  local root = parser:parse()[1]:root()
  local sections = M.getSections(root)
  local directives = M.getDirectives(root, M.contentBuffer)

  local toSlide = function(node)
    local startr, _, endr, _ = vim.treesitter.get_node_range(node)
    local lines = vim.api.nvim_buf_get_lines(M.contentBuffer, startr, endr, false)
    return Slide:new { name = "--", lines = lines }
  end

  local slides = vim.tbl_map(toSlide, sections)
  if directives.title then
    local introHeading = M.figletBlog(directives.title)
    local intro = Slide:new { name = "Intro", lines = introHeading }
    table.insert(slides, 1, intro)
  end
  local outroHeading = M.figletBlog(directives.outro or 'End of presentation')
  local outro = Slide:new { name = "Outro", lines = outroHeading }
  table.insert(slides, outro)

  return slides
end

function M.figletBlog(text)
  local block = M.figlet(text)
  table.insert(block, 1, '#+begin_src')
  table.insert(block, '#+end_src')
  return block
end

function M.figlet(text)
  local w = M.config.width(vim.o.columns)
  local cmd = { 'figlet', '-c', '-w', w, text }
  local result = vim.system(cmd, {}):wait()
  local lines = {}
  for line in string.gmatch(result.stdout, "[^\n]+") do
    table.insert(lines, line)
  end
  return lines
end

function M.createSlideBuffer()
  M.buffer = vim.api.nvim_create_buf(false, true)

  vim.api.nvim_set_option_value('filetype', 'org', { buf = M.buffer })

  local opts = { buffer = M.buffer, nowait = true }
  vim.keymap.set('n', 'q', function() M.close() end, opts)
  vim.keymap.set('n', 'n', function() M.nextSlide() end, opts)
  vim.keymap.set('n', 'p', function() M.previousSlide() end, opts)

  return M.buffer
end

function M.nextSlide() M.setSlideIndex(M.state.currentSlide + 1) end

function M.previousSlide() M.setSlideIndex(M.state.currentSlide - 1) end

function M.setSlideIndex(index)
  if index <= 0 then return end
  if index > #M.state.slides then return end

  M.state.currentSlide = index
  local slide = M.state.slides[M.state.currentSlide]
  vim.api.nvim_buf_set_lines(M.buffer, 0, -1, false, slide:getLines())

  print("Slide: " .. M.state.currentSlide .. "/" .. #M.state.slides)
end

function M.createBackground()
  empty_buffer = vim.api.nvim_create_buf(false, true)
  background = vim.api.nvim_open_win(empty_buffer, false, {
    relative = 'editor',
    style = 'minimal',
    zindex = 100,
    focusable = false,
    width = 1,
    height = 1,
    row = 0,
    col = 0,
  })
  vim.api.nvim_win_set_hl_ns(background, M.namespace_id)
end

function M.createWindow(buffer)
  M.window = vim.api.nvim_open_win(buffer, true, {
    relative = 'editor',
    style = 'minimal',
    zindex = 110,
    focusable = true,
    width = 50,
    height = 10,
    row = 5,
    col = 5,
  })

  vim.api.nvim_win_set_hl_ns(M.window, M.namespace_id)
  vim.api.nvim_set_option_value('winfixbuf', true, { win = M.window })
  vim.api.nvim_set_option_value('conceallevel', 2, { win = M.window })
  vim.api.nvim_set_option_value('concealcursor', 'nvc', { win = M.window })
  vim.api.nvim_set_option_value('listchars', '', { win = M.window })
end

function M.configure()
  M.state.slides = M.prepareSlides()
  M.setSlideIndex(M.state.currentSlide)

  local width = vim.o.columns
  local height = vim.o.lines
  local slideWidth = math.floor(M.config.width(width))
  local slideHeight = math.floor(M.config.height(height))

  vim.api.nvim_win_set_width(background, width)
  vim.api.nvim_win_set_height(background, height)

  vim.api.nvim_win_set_config(M.window, {
    relative = 'editor',
    row = math.floor((height - slideHeight) / 2),
    col = math.floor((width - slideWidth) / 2),
    width = slideWidth,
    height = slideHeight,
  })
end

function M.close()
  vim.api.nvim_clear_autocmds({ group = M.group })
  vim.api.nvim_win_close(M.window, true)
  vim.api.nvim_win_close(background, true)
  vim.api.nvim_buf_delete(M.buffer, { force = true })
  vim.api.nvim_buf_delete(empty_buffer, { force = true })
end

return M
