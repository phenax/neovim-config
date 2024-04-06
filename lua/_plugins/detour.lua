local M = {}
local plugin = {
  'carbon-steel/detour.nvim',
  keys = {
    { '<c-w>.', ':DetourCurrentWindow<cr>', mode = 'n' },
    { '<C-t>d', function() M.stack_jump_to_defn() end, mode = 'n' },
    { '<C-t>r', function() M.stack_references() end, mode = 'n' },
  },
  dependencies = {
    'nvim-telescope/telescope.nvim',
  },
}

function plugin.config() end

function M.stack_jump_to_defn()
  local detour = require 'detour'
  local features = require 'detour.features'

  local popup_id = detour.Detour()
  if popup_id then
    require('telescope.builtin').lsp_definitions {}
    features.ShowPathInTitle(popup_id)
  end
end

function M.stack_references()
  local detour = require 'detour'
  local features = require 'detour.features'

  local popup_id = detour.Detour()
  if popup_id then
    require('telescope.builtin').lsp_references {
      include_declaration = false,
      include_current_line = false,
    }
    features.ShowPathInTitle(popup_id)
  end
end

return plugin
