-- [nfnl] fnl/_plugins/copilot.fnl
local m = {}
local function config()
  vim.g.copilot_enabled = false
  local function _1_()
    return m.toggle_copilot()
  end
  return vim.keymap.set("n", "<leader>sm", _1_)
end
m.toggle_copilot = function()
  if vim.g.copilot_enabled then
    vim.cmd("Copilot disable")
    print("Copilot disabled")
    vim.g.copilot_enabled = false
    return nil
  else
    vim.cmd("Copilot enable")
    print("Copilot enabled")
    vim.g.copilot_enabled = true
    return nil
  end
end
return {config = config}
