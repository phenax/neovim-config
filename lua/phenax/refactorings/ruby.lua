-- [nfnl] fnl/phenax/refactorings/ruby.fnl
local tsutils = require("phenax.utils.treesitter")
local core = require("nfnl.core")
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local shared = require("phenax.refactorings.shared")
local ruby = {}
ruby.initialize = function()
  local function _2_()
    return ruby.setup_current_buf()
  end
  return vim.api.nvim_create_autocmd("FileType", {pattern = {"ruby"}, callback = _2_})
end
ruby.setup_current_buf = function()
  local function _3_()
    pcall(ruby.include_memery_around_class)
    return "memoize"
  end
  vim.keymap.set("ia", "memoize", _3_, {buffer = true, expr = true})
  vim.keymap.set("ia", "def", "def\nend<Up>", {buffer = true})
  vim.keymap.set("ia", "context", "context 'when' do\nend<Up><c-o>fn<Right>", {buffer = true})
  vim.keymap.set("ia", "it", "it 'does' do\nend<Up><c-o>fs<Right>", {buffer = true})
  vim.keymap.set("ia", "let", "let(:) { }<c-o>4h", {buffer = true})
  return vim.keymap.set("v", "<leader>rev", ruby.extract_selected_text_as_method, {buffer = true})
end
ruby.get_parent_statement = function(node)
  local parent = (tsutils.find_closest_parent_of_type(node, {"class", "module"}) or tsutils.get_root_node(0))
  if not_nil_3f(parent) then
    local body = parent
    for n, _ in parent:iter_children() do
      if (n:type() == "body_statement") then
        body = n
      else
      end
    end
    local _val__2_auto = body
    return (_val__2_auto and _val__2_auto:child_with_descendant(node))
  else
    return nil
  end
end
ruby.extract_selected_text_as_method = function()
  local function create_declr(opts)
    _G.assert((nil ~= opts), "Missing argument opts on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/ruby.fnl:32")
    local indent = tsutils.get_node_indentation(opts.node)
    local declr_lines = {"", (indent .. "def " .. opts.name)}
    vim.list_extend(declr_lines, opts.selected_lines)
    table.insert(declr_lines, (indent .. "end"))
    return shared.insert_after_node(opts.node, declr_lines, (( - #opts.selected_lines) + 1))
  end
  return shared.extract_selected_text({create_declaration = create_declr, get_parent_statement = ruby.get_parent_statement})
end
ruby.include_memery_around_class = function()
  local node = tsutils.get_node_at_cursor()
  local class_node = tsutils.find_closest_parent_of_type(node, {"class"})
  if not_nil_3f(class_node) then
    local buf = vim.api.nvim_get_current_buf()
    local function _6_()
      return ruby.include_memery_in_class_node(buf, class_node)
    end
    return vim.schedule(_6_)
  else
    return nil
  end
end
ruby.include_memery_in_class_node = function(buf, class_node)
  local start_row, _, _0 = class_node:start()
  if not ruby["includes_memery?"](buf, class_node) then
    local indent = tsutils.get_node_indentation(class_node)
    return vim.api.nvim_buf_set_lines(buf, (start_row + 1), (start_row + 1), false, {(indent .. "include Memery")})
  else
    return nil
  end
end
ruby["includes_memery?"] = function(buf, class_node)
  local function body_statement_3f(node)
    _G.assert((nil ~= node), "Missing argument node on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/ruby.fnl:57")
    core.println(node)
    return (node:type() == "body_statement")
  end
  local function text_includes_memory_3f(node)
    _G.assert((nil ~= node), "Missing argument node on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/ruby.fnl:58")
    return string.match(vim.treesitter.get_node_text(node, buf), "include%s+Memery")
  end
  local function is_body_statement_with_memery_3f(node)
    _G.assert((nil ~= node), "Missing argument node on /home/imsohexy/nixos/config/nvim/fnl/phenax/refactorings/ruby.fnl:61")
    return (body_statement_3f(node) and text_includes_memory_3f(node))
  end
  local function _10_(_9_, _)
    local node = _9_[1]
    return is_body_statement_with_memery_3f(node)
  end
  return core.some(_10_, vim.iter(class_node:iter_children()):totable())
end
return ruby
