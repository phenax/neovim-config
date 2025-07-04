local M = {}
local plugin = {
  'github/copilot.vim',
  keys = {
    { mode = 'n', '<leader>sm', function() M.toggle_copilot() end },
  },
  config = function()
    vim.g.copilot_enabled = false
    -- vim.g.copilot_no_tab_map = true
  end,
}

function M.toggle_copilot()
  if (vim.g.copilot_enabled) then
    vim.cmd [[Copilot disable]]
    print 'Copilot disabled'
    vim.g.copilot_enabled = false
  else
    vim.cmd [[Copilot enable]]
    print 'Copilot enabled'
    vim.g.copilot_enabled = true
  end
end

return plugin
