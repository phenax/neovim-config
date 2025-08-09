-- [nfnl] fnl/phenax/refactorings/js.fnl
local tsutils = require("phenax.utils.treesitter")
local text = require("phenax.utils.text")
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local shared = require("phenax.refactorings.shared")
local js = {}
js.initialize = function()
  local function _2_()
    return js.setup_current_buf()
  end
  return vim.api.nvim_create_autocmd("FileType", {pattern = {"javascript", "typescript", "javascriptreact", "typescriptreact"}, callback = _2_})
end
js.setup_current_buf = function()
  local function _3_()
    pcall(js.wrap_async_around_closest_function)
    return "await"
  end
  vim.keymap.set("ia", "await", _3_, {buffer = true, expr = true})
  vim.keymap.set("ia", "describe", "describe('when', () => {\n})<Up><c-o>fn<Right>", {buffer = true})
  vim.keymap.set("ia", "it", "it('does', () => {\n})<Up><c-o>fs<Right>", {buffer = true})
  vim.keymap.set("v", "<leader>rll", js.add_log_for_selected_text, {buffer = true})
  return vim.keymap.set("v", "<leader>rev", js.extract_selected_text_as_value, {buffer = true})
end
js.add_log_for_selected_text = function()
  local node = tsutils.get_node_at_cursor(0)
  local stmnt = js.get_parent_statement(node)
  if not_nil_3f(stmnt) then
    local contents = text.get_selection_text():gsub("[\n]*", "")
    local end_row, _ = stmnt:end_()
    local log_text = ("console.log(" .. vim.json.encode((":: [" .. contents .. "]")) .. ", " .. contents .. ")")
    return vim.api.nvim_buf_set_lines(0, (end_row + 1), (end_row + 1), false, {(tsutils.get_node_indentation(stmnt) .. log_text)})
  else
    return nil
  end
end
js.extract_selected_text_as_value = function()
  local function create_declr(opts)
    _G.assert((nil ~= opts), "Missing argument opts on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/js.fnl:37")
    local indent = tsutils.get_node_indentation(opts.node)
    local declr_lines = {(indent .. "const " .. opts.name .. " = " .. opts.selected_lines[1])}
    vim.list_extend(declr_lines, vim.list_slice(opts.selected_lines, 2))
    return shared.insert_before_node(opts.node, declr_lines)
  end
  return shared.extract_selected_text({create_declaration = create_declr, get_parent_statement = js.get_parent_statement})
end
js.wrap_async_around_closest_function = function()
  local node = tsutils.get_node_at_cursor()
  local parent_func = js.find_closest_parent_func(node)
  if not_nil_3f(parent_func) then
    local buf = vim.api.nvim_get_current_buf()
    local function _5_()
      return pcall(js.add_async_around_node, buf, parent_func)
    end
    return vim.schedule(_5_)
  else
    return nil
  end
end
js.add_async_around_node = function(buf, func_node)
  local start_row, start_col, _ = func_node:start()
  local line = vim.api.nvim_buf_get_lines(buf, start_row, (start_row + 1), false)[1]
  local has_async_keyword_3f = string.match(string.sub(line, (start_col + 1)), "^%s*async%s+")
  if not has_async_keyword_3f then
    local asynced_line = (line:sub(1, start_col) .. "async " .. line:sub((start_col + 1)))
    return vim.api.nvim_buf_set_lines(buf, start_row, (start_row + 1), false, {asynced_line})
  else
    return nil
  end
end
js.get_parent_statement = function(node)
  local parent = (tsutils.find_closest_parent_of_type(node, {"statement_block"}) or tsutils.get_root_node(0))
  local _val__2_auto = parent
  return (_val__2_auto and _val__2_auto:child_with_descendant(node))
end
js.find_closest_parent_func = function(node)
  return tsutils.find_closest_parent_of_type(node, {"function_expression", "function_declaration", "arrow_function", "method_definition"})
end
return js
