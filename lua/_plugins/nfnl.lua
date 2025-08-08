-- [nfnl] fnl/_plugins/nfnl.fnl
local core = require("nfnl.core")
local fnl = require("nfnl.fennel")
local plugin = {}
local function run_fnl(code)
  return core.println(fnl.eval(core.str("(local core (require :nfnl.core))", code)))
end
plugin.config = function()
  vim.keymap.set("n", "<c-n>d", "<cmd>NfnlDeleteOrphans<cr>")
  local function _1_()
    return run_fnl("(print 'TODO: impl')")
  end
  vim.keymap.set("n", "<c-n>x", _1_)
  local function _2_(val_1_auto)
    return run_fnl(val_1_auto.args)
  end
  return vim.api.nvim_create_user_command("Fnl", _2_, {nargs = "*"})
end
return plugin
