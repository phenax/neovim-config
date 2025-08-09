-- [nfnl] fnl/_plugins/autopairs.fnl
local autopairs = require("nvim-autopairs")
local function config()
  return autopairs.setup({disable_filetype = {"snacks_picker_input"}, map_c_h = true, map_c_w = true})
end
return {config = config}
