-- [nfnl] fnl/_plugins/autotag.fnl
local autotag = require("nvim-ts-autotag")
local function opts()
  return {opts = {enable_close = true, enable_close_on_slash = true, enable_rename = true}}
end
local function config()
  return autotag.setup(opts())
end
return {config = config}
