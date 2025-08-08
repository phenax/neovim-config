-- [nfnl] fnl/_settings/init.fnl
require("_settings.settings")
require("_settings.basic-keybinds")
require("_settings.ft")
do
  local theme = require("_settings.theme")
  theme.setup("default")
end
require("_settings.packages")
local pack = require("phenax.pack_config")
return pack.load("_plugins")
