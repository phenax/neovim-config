local M = {}

function M.initialize()
  require 'phenax.refactorings.ruby'.initialize()
  require 'phenax.refactorings.js'.initialize()
end

return M
