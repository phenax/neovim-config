local M = {}

function M.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = 'org',
    group = vim.api.nvim_create_augroup('phenax/orgmode_links', { clear = true }),
    callback = function()
      vim.keymap.set('n', '<Tab>', function() M.jumpToNextLink() end, { buffer = true })
      vim.keymap.set('n', '<S-Tab>', function() M.jumpToPreviousLink() end, { buffer = true })
      vim.keymap.set('n', '<CR>', function() M.openAtCursor() end, { buffer = true })
      vim.keymap.set('n', '<M-e>', function() M.executeBlockAtCursor() end, { buffer = true })
      vim.keymap.set('n', 'gx', function() M.openAtCursorExt() end, { buffer = true })
      vim.keymap.set('n', '<leader>gi', function() M.openAtCursorImage() end, { buffer = true })
    end,
  })
end

function _OpenImage(path) vim.cmd('!feh -x -F --image-bg "#0f0c19" ' .. path) end

function M.openAtCursorExt()
  local cursorLink = M.linkAtCursor()
  if cursorLink and cursorLink.url then
    local fullPath = cursorLink.url:get_real_path() or cursorLink.url:get_file_path()
    if fullPath then
      vim.ui.open(fullPath)
    end
  end
end

function M.openAtCursor()
  local cursorLink = M.linkAtCursor()
  if cursorLink and cursorLink.url and cursorLink.url.url:find('^+') ~= nil then
    local cmd = cursorLink.url.url:sub(2)
    print('Running: ' .. cmd)
    return vim.cmd(cmd)
  end
  return require 'orgmode'.action('org_mappings.open_at_point')
end

function M.jumpToNextLink() M.jumpToLink(M.nextLink) end

function M.jumpToPreviousLink() M.jumpToLink(M.previousLink) end

function M.nextLink(links, cursor)
  local linksBeforeCursor = vim.tbl_filter(function(link)
    local rowdist = link.range.start_line - cursor[1]
    local coldist = link.range.start_col - cursor[2]
    return rowdist > 0 or (rowdist == 0 and coldist > 0)
  end, links)

  return M.getClosestLinkToCursor(linksBeforeCursor, cursor)
end

function M.previousLink(links, cursor)
  local linksBeforeCursor = vim.tbl_filter(function(link)
    local rowdist = link.range.start_line - cursor[1]
    local coldist = link.range.start_col - cursor[2]
    return rowdist < 0 or (rowdist == 0 and coldist < 0)
  end, links)

  return M.getClosestLinkToCursor(linksBeforeCursor, cursor)
end

function M.jumpToLink(getLink)
  local links = M.getDocLinks()
  local win_id = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win_id)
  local link = getLink(links, cursor)
  if link ~= nil then
    vim.api.nvim_win_set_cursor(win_id, { link.range.start_line, link.range.start_col })
  end
end

function M.executeBlockAtCursor()
  local orgmodeApi = require 'orgmode.api'
  local blocks = orgmodeApi:current()._file:get_blocks()
  for _, block in ipairs(blocks) do
    local startRow, _, endRow, _ = block.node:range(false)
    local row = vim.api.nvim_win_get_cursor(0)[1]

    if startRow <= row and endRow >= row then
      local lang = block:get_language() or "lua"
      local eval = M.evaluator[lang]
      if eval == nil then return error("No evaluator for " .. lang) end

      local code = table.concat(block:get_content(), '\n')
      eval(code, function(d) print(d) end)
    end
  end
end

local cleanOutput = function(cb)
  return function(_, data)
    if data == nil then return end
    if type(data) == "string" then return cb(data:gsub("%s+$", "")) end
    return cb(data)
  end
end

M.evaluator = {
  lua = function(code, onResult) onResult(load(code)()) end,
  bash = function(code, onResult)
    vim.system({ 'bash', '-c', code }, {
      stdout = cleanOutput(onResult),
      stderr = cleanOutput(onResult),
      text = true,
    })
  end,
  javascript = function(code, onResult)
    vim.system({ 'node', '-e', code }, {
      stdout = cleanOutput(onResult),
      stderr = cleanOutput(onResult),
      text = true,
    })
  end
}

function M.linkAtCursor()
  local links = M.getDocLinks()
  if links[1] then return links[1]:at_cursor() end
  return nil
end

function M.getDocLinks()
  local orgmode_api = require 'orgmode.api'
  local file = orgmode_api.current()
  return file._file:get_links()
end

function M.getClosestLinkToCursor(links, cursor)
  local closest_dist = math.huge
  local closest_link = nil

  for _, link in ipairs(links) do
    local distance = M.cursorDistance({ link.range.start_line, link.range.start_col }, cursor)
    if distance < closest_dist then
      closest_dist = distance
      closest_link = link
    end
  end

  return closest_link
end

-- {row, column} -> {row, column} -> number
function M.cursorDistance(a, b)
  if a[1] == b[1] then
    return math.abs(b[2] - a[2])
  end
  -- return 500 * math.abs(b[1] - a[1]) + math.abs(b[2] - a[2])
  return 2 * math.abs(b[1] - a[1])
end

return M
