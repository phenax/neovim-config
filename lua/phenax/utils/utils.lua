-- [nfnl] fnl/phenax/utils/utils.fnl
local _local_1_ = require("nfnl.core")
local empty_3f = _local_1_["empty?"]
local nil_3f = _local_1_["nil?"]
local utils = {}
utils["present?"] = function(val)
  return not empty_3f(val)
end
utils["not_nil?"] = function(val)
  return not nil_3f(val)
end
utils.clamp = function(n, min, max)
  return math.min(math.max(n, min), (max or math.huge))
end
return utils
