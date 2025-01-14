local M = {}
local plugin = {
  'github/copilot.vim',
  event = 'VeryLazy',
  keys = {
    { mode = 'n', '<leader>sm', function() M.toggleCopilot() end },
    { mode = 'i', '<C-l>',      '<Plug>(copilot-accept-word)' },
    { mode = 'i', '<m-]>',      '<Plug>(copilot-next)' },
    { mode = 'i', '<m-[>',      '<Plug>(copilot-previous)' },
    { mode = 'i', '<C-y>',      'copilot#Accept("")',            expr = true },
  },
  config = function()
    vim.g.copilot_enabled = false
    vim.g.copilot_no_tab_map = true
  end,
}

function M.toggleCopilot()
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
