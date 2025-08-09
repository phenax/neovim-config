-- [nfnl] fnl/_plugins/mini-surround.fnl
local mini_surround = require("mini.surround")
local function config()
  return mini_surround.setup({mappings = {add = "sa", delete = "sd", find = "sf", find_left = "sF", highlight = "sh", replace = "sc", suffix_last = "l", suffix_next = "n"}, n_lines = 40, respect_selection_type = true})
end
return {config = config}
