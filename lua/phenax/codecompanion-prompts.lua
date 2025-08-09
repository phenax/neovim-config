-- [nfnl] fnl/phenax/codecompanion-prompts.fnl
local M = {}
M["Review buffer"] = {strategy = "chat", description = "Review code in buffer", prompts = {{role = "system", content = "I want you to act as an expert senior developer and code reviewer.\nI want you to review the given code and architecture thoroughly."}, {role = "user", opts = {contains_code = true}, content = "Carefully read the provided code and identify any potential issues or improvements.\nThings to keep in mind:\n  1. Ensure the code follows the best practises for the given language\n  2. Identify bug prone parts and provide solutions\n  3. Identify the problem being solved and ensure the approach is optimal\n  4. Ensure the code is readable and has a sound structure\n  5. Ensure the code follows the best practises in regards to security\n\nDo not return the corrected code, only the review for it. Your answer should be concise and only provide bullet points.\n#{buffer}"}}}
local function _1_(context)
  return ("The programming language is " .. context.filetype .. ". Please explain the diagnostics #lsp")
end
M["Explain LSP"] = {strategy = "chat", description = "Explain the LSP diagnostics for the selected code", prompts = {{role = "system", content = "You are an expert coder and helpful assistant who can help debug code diagnostics, such as warning and error messages.\nWhen appropriate, give solutions with code snippets as fenced codeblocks with a language identifier to enable syntax highlighting"}, {role = "user", content = _1_}}}
return M
