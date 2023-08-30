local M = {}

function M.setup()
  require'marks'.setup {
    default_mappings = true,
    -- mappings = {}
  }
end

return M
