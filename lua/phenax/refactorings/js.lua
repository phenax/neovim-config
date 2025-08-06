local tsutils = require 'phenax.utils.treesitter'
local text = require 'phenax.utils.text'
local shared = require 'phenax.refactorings.shared'
local M = {}

function M.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    callback = function()
      vim.keymap.set('ia', 'await', function()
        pcall(M.wrap_async_around_closest_function)
        return 'await'
      end, { buffer = true, expr = true })
      vim.keymap.set('ia', 'describe', "describe('when', () => {\n})<Up><c-o>fn<Right>", { buffer = true })
      vim.keymap.set('ia', 'it', "it('does', () => {\n})<Up><c-o>fs<Right>", { buffer = true })

      vim.keymap.set('v', '<leader>rll', M.add_log_for_selected_text, { buffer = true })
      vim.keymap.set('v', '<leader>rev', M.extract_selected_text_as_value, { buffer = true })

      -- TODO: Keybind to toggle `it`/`it.only` in the current block
    end,
  })
end

function M.add_log_for_selected_text()
  local node = tsutils.get_node_at_cursor(0)
  if not node then return end
  local contents = text.get_selection_text():gsub('[\n]*', '')

  local stmnt = M.get_parent_statement(node)
  if not stmnt then return end

  local end_row, _ = stmnt:end_()
  local log_text = 'console.log(' .. vim.json.encode(':: [' .. contents .. ']') .. ', ' .. contents .. ')'
  vim.api.nvim_buf_set_lines(0, end_row + 1, end_row + 1, false, { tsutils.get_node_indentation(stmnt) .. log_text })
end

function M.extract_selected_text_as_value()
  shared.extract_selected_text({
    get_parent_statement = M.get_parent_statement,
    --- @param opts DeclrOpts
    create_declaration = function(opts)
      local indent = tsutils.get_node_indentation(opts.node)
      local declr_lines = { indent .. 'const ' .. opts.name .. ' = ' .. opts.selected_lines[1] }
      vim.list_extend(declr_lines, vim.list_slice(opts.selected_lines, 2))
      shared.insert_before_node(opts.node, declr_lines)
    end
  })
end

function M.wrap_async_around_closest_function()
  local node = tsutils.get_node_at_cursor()
  if node == nil then return end

  local parent_func = M.find_closest_parent_func(node)
  if parent_func == nil then return end

  local buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    pcall(M.add_async_around_node, buf, parent_func)
  end)
end

function M.add_async_around_node(buf, func_node)
  local start_row, start_col, _ = func_node:start()

  local line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
  if not line:sub(start_col + 1):match('^%s*async%s+') then
    local asynced_line = line:sub(1, start_col) .. 'async ' .. line:sub(start_col + 1)
    vim.api.nvim_buf_set_lines(buf, start_row, start_row + 1, false, { asynced_line })
  end
end

function M.get_parent_statement(node)
  local parent = tsutils.find_closest_parent_of_type(node, { 'statement_block' }) or tsutils.get_root_node(0)
  return parent and parent:child_with_descendant(node)
end

function M.find_closest_parent_func(node)
  return tsutils.find_closest_parent_of_type(node, {
    'function_expression',
    'function_declaration',
    'arrow_function',
    'method_definition',
  })
end

return M
