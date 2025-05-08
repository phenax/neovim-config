local M = {}

M['Lorem Ipsum'] = {
  strategy = 'inline',
  description = 'Generate boilerplate text content',
  opts = { ignore_system_prompt = true },
  prompts = {
    {
      role = 'user',
      content =
      [[Please generate some random boilerplate text content to fill at least 2 paragraphs.
              Make the text realistic and not lorem ipsum. Return just the text content]],
    },
  },
}

M['Review buffer'] = {
  strategy = 'chat',
  description = 'Review code in buffer',
  prompts = {
    {
      role = 'system',
      content =
      [[I want you to act as an expert senior developer and code reviewer.
I want you to review the given code and architecture thoroughly.]],
    },

    {
      role = 'user',
      content = [[
Carefully read the provided code and identify any potential issues or improvements.
Things to keep in mind:
  1. Ensure the code follows the best practises for the given language
  2. Identify bug prone parts and provide solutions
  3. Identify the problem being solved and ensure the approach is optimal
  4. Ensure the code is readable and has a sound structure
  5. Ensure the code follows the best practises in regards to security

Do not return the corrected code, only the review for it. Your answer should be concise and only provide bullet points.
#buffer]],
      opts = { contains_code = true },
    },
  },
}

M['Explain LSP'] = {
  strategy = 'chat',
  description = 'Explain the LSP diagnostics for the selected code',
  prompts = {
    {
      role = 'system',
      content =
      [[You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages.
When appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting]],
    },
    {
      role = 'user',
      content = function(context)
        return 'The programming language is ' .. context.filetype .. '. Please explain the diagnostics #lsp'
      end,
    },
  },
}

-- M['Generate a README'] = {
--   strategy = 'inline',
--   description = 'Generate a README',
--   prompts = {
--     {
--       role = 'system',
--       content = [[You are an expert senior developer]],
--     },
--     {
--       role = 'user',
--       content = function(context)
--         return [[
--
--         ]]
--       end,
--     },
--   },
-- }

return M
