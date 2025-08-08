-- [nfnl] fnl/phenax/utils/utils.fnl
local _local_1_ = require("nfnl.core")
local empty_3f = _local_1_["empty?"]
local utils = {}
utils["present?"] = function(val)
  return not empty_3f(val)
end
return utils
