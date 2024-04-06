local plugin = {
  'artemave/workspace-diagnostics.nvim',
  cmd = 'LspLoadAll',
  enabled = false,
}

local M = {
  ignore_lsp = {
    'copilot',
    'tailwindcss',
  },
}

function plugin.config()
  vim.api.nvim_create_user_command('LspLoadAll', function() M.activate() end, { nargs = 0 })
end

function M.activate()
  local clients = vim.lsp.get_active_clients()
  for _, c in ipairs(clients) do
    if not vim.tbl_contains(M.ignore_lsp, c.name) then M.run_on_current_buffer(c) end
  end
end

function M.run_on_current_buffer(client)
  if client ~= nil then
    print('Populating diagnostics for ' .. client.name .. '...')
    local bufnr = vim.api.nvim_get_current_buf()
    require('workspace-diagnostics').populate_workspace_diagnostics(client, bufnr)
  end
end

return plugin
