local shared = require 'phenax.refactorings.shared'
local tsutils = require 'phenax.utils.treesitter'
local M = {}

function M.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'ruby' },
    callback = function()
      vim.keymap.set('ia', 'memoize', function()
        pcall(M.include_memery_around_closest_class)
        return 'memoize'
      end, { buffer = true, expr = true })
      vim.keymap.set('ia', 'def', 'def\nend<Up>', { buffer = true })
      vim.keymap.set('ia', 'context', "context 'when' do\nend<Up><c-o>fn<Right>", { buffer = true })
      vim.keymap.set('ia', 'it', "it 'does' do\nend<Up><c-o>fs<Right>", { buffer = true })
      vim.keymap.set('ia', 'let', 'let(:) { }<c-o>4h', { buffer = true })

      vim.keymap.set('v', '<leader>rev', M.extract_selected_text_as_method, { buffer = true })
    end,
  })
end

function M.get_parent_statement(node)
  local parent = tsutils.find_closest_parent_of_type(node, { 'class', 'module' }) or tsutils.get_root_node(0)
  if not parent then return nil end
  local body = parent
  for n, _ in parent:iter_children() do
    if n:type() == 'body_statement' then body = n end
  end
  return body and body:child_with_descendant(node)
end

function M.extract_selected_text_as_method()
  shared.extract_selected_text({
    get_parent_statement = M.get_parent_statement,
    --- @param opts DeclrOpts
    create_declaration = function(opts)
      local indent = tsutils.get_node_indentation(opts.node)
      local declr_lines = { '', indent .. 'def ' .. opts.name }
      vim.list_extend(declr_lines, opts.selected_lines)
      table.insert(declr_lines, indent .. 'end')
      shared.insert_after_node(opts.node, declr_lines, - #opts.selected_lines + 1)
    end
  })
end

function M.include_memery_around_closest_class()
  local node = tsutils.get_node_at_cursor()
  if node == nil then return end

  local class_node = tsutils.find_closest_parent_of_type(node, { 'class' })
  if class_node == nil then return end

  local buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    -- pcall(M.include_memery_in_class_node, buf, class_node)
    M.include_memery_in_class_node(buf, class_node)
  end)
end

--- @param buf number
--- @param class_node TSNode
function M.include_memery_in_class_node(buf, class_node)
  local start_row, _, _ = class_node:start()
  if M.has_included_memery(buf, class_node) then return end
  local indent = tsutils.get_node_indentation(class_node)
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
