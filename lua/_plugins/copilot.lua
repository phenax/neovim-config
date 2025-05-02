local M = {}
local plugin = {
  'github/copilot.vim',
  event = 'VeryLazy',
  keys = {
    { mode = 'n', '<leader>sm', function() M.toggle_copilot() end },
  },
  config = function()
    vim.g.copilot_enabled = true
    vim.g.copilot_no_tab_map = true

    vim.api.nvim_create_autocmd({ 'FileType', 'BufUnload' }, {
      group = vim.api.nvim_create_augroup('github_copilot', { clear = true }),
      callback = function(args)
        vim.fn['copilot#On' .. args.event]()
      end,
    })
    vim.fn['copilot#OnFileType']()
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
