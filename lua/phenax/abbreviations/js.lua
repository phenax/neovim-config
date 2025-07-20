local utils = require 'phenax.utils.treesitter'
local M = {}

function M.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
    callback = function()
      vim.keymap.set('ia', 'await', function()
        pcall(M.wrap_async)
        return 'await'
      end, { buffer = true, expr = true })

      vim.keymap.set('ia', 'log!', M.add_console_log, { buffer = true, expr = true })
    end,
  })
end

function M.add_console_log()
  local file, line = vim.fn.expand('%:t'), vim.fn.line('.')
  return "console.log('[" .. file .. ':' .. line .. "]',)<Left>"
end

function M.find_closest_parent_func(node)
  return utils.find_closest_parent_of_type(node, {
    'function_expression',
    'function_declaration',
    'arrow_function',
    'method_definition',
  })
end

function M.wrap_async()
  local node = utils.get_node_at_cursor()
  if node == nil then return end

  local parent_func = M.find_closest_parent_func(node)
  if parent_func == nil then return end

  local start_row, start_col, _ = parent_func:start()

  local buf = vim.api.nvim_get_current_buf()
  vim.schedule(function()
    local line = vim.api.nvim_buf_get_lines(buf, start_row, start_row + 1, false)[1]
    if not line:sub(start_col + 1):match('^%s*async%s+') then
      local asynced_line = line:sub(1, start_col) .. 'async ' .. line:sub(start_col + 1)
      vim.api.nvim_buf_set_lines(buf, start_row, start_row + 1, false, { asynced_line })
    end
  end)
end

return M
