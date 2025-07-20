local utils = require 'phenax.utils.treesitter'
local M = {}

function M.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'ruby' },
    callback = function()
      vim.keymap.set('ia', 'memoize', function()
        pcall(M.wrap_include_memery)
        return 'memoize'
      end, { buffer = true, expr = true })

      -- autocomplete
      vim.keymap.set('ia', 'def', 'def\nend<Up>', { buffer = true })
      vim.keymap.set('ia', 'context', "context 'when ' do\nend<Up>", { buffer = true })
      vim.keymap.set('ia', 'it', "it 'does ' do\nend<Up>", { buffer = true })
      vim.keymap.set('ia', 'let', 'let(:) { }<c-o>4h', { buffer = true })
    end,
  })
end

function M.wrap_include_memery()
  local node = utils.get_node_at_cursor()
  if node == nil then return end

  local class_node = utils.find_closest_parent_of_type(node, { 'class' })
  if class_node == nil then return end

  local buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    pcall(M.add_include_memery, buf, class_node)
  end)
end

--- @param buf number
--- @param class_node TSNode
function M.add_include_memery(buf, class_node)
  local start_row, _, _ = class_node:start()
  if M.has_included_memery(buf, class_node) then return end
  local indent = string.rep(' ', vim.fn.indent(start_row + 1) + 2)
  vim.api.nvim_buf_set_lines(buf, start_row + 1, start_row + 1, false, { indent .. 'include Memery' })
end

--- @param buf number
--- @param class_node TSNode
function M.has_included_memery(buf, class_node)
  for class_call, _ in class_node:iter_children() do
    if class_call:type() == 'body_statement' then
      local text = vim.treesitter.get_node_text(class_call, buf)
      if string.match(text, 'include%s+Memery') then return end
    end
  end
end

return M
