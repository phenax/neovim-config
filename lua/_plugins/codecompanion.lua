return {
  keys = {
    { mode = { 'n', 'x' }, '<a-c>c', '<cmd>CodeCompanionChat Toggle<cr>' },
    { mode = { 'n', 'x' }, '<a-c>a', '<cmd>CodeCompanionChat Add<cr>' },
    { mode = { 'n', 'x' }, '<a-c>e', '<cmd>CodeCompanion /explain<cr>' },
    { mode = { 'n', 'x' }, '<a-c>p', '<cmd>CodeCompanionActions<cr>' },
  },

  config = function()
    require 'codecompanion'.setup {
      strategies = {
        chat = { adapter = 'copilot' },
        inline = { adapter = 'copilot' },
        agent = { adapter = 'copilot' },
      },
      prompt_library = require 'phenax.codecompanion-prompts',
    }
  end,
}
-- ga: accept diff
-- gr: reject diff
