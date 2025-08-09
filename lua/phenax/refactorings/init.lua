-- [nfnl] fnl/phenax/refactorings/init.fnl
local refactorings = {}
refactorings.initialize = function()
  require("phenax.refactorings.ruby").initialize()
  return require("phenax.refactorings.js").initialize()
end
return refactorings
