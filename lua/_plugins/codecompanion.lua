-- [nfnl] fnl/_plugins/codecompanion.fnl
local codecompanion = require("codecompanion")
local function config()
  vim.keymap.set({"n", "x"}, "<a-c>c", "<cmd>CodeCompanionChat Toggle<cr>")
  vim.keymap.set({"n", "x"}, "<a-c>a", "<cmd>CodeCompanionChat Add<cr>")
  vim.keymap.set({"n", "x"}, "<a-c>e", "<cmd>CodeCompanion /explain<cr>")
  vim.keymap.set({"n", "x"}, "<a-c>p", "<cmd>CodeCompanionActions<cr>")
  return codecompanion.setup({prompt_library = require("phenax.codecompanion-prompts"), strategies = {agent = {adapter = "copilot"}, chat = {adapter = "copilot", opts = {completion_provider = "blink"}}, inline = {adapter = "copilot"}}})
end
return {config = config}
