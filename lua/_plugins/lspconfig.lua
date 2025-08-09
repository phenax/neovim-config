-- [nfnl] fnl/_plugins/lspconfig.fnl
local lspconfig = require("lspconfig")
local blink = require("blink.cmp")
local nfnl_config = require("nfnl.config")
local plugin = {}
local function cap_disable_formatting(cap)
  cap.textDocument.formatting = false
  return cap
end
local config = {is_autoformat_enabled = true}
local function _1_()
  return vim.cmd("EslintFixAll")
end
local function _2_()
  return vim.cmd("sil !fnlfmt --fix %")
end
config.alt_formatters = {eslint = _1_, fennel_ls = _2_}
config.format_on_save_ft = {"astro", "c", "cpp", "crystal", "elm", "go", "h", "haskell", "java", "javascript", "javascriptreact", "lua", "nix", "purescript", "racket", "ruby", "rust", "scala", "svelte", "typescript", "typescriptreact", "uiua", "unison", "vue", "gleam"}
local function _3_()
  return {biome = {}, clangd = {}, eslint = {}, fennel_ls = config["get-fennel-ls-config"](), gopls = {}, hls = config["get-hls-config"](), jsonls = {init_options = {provideFormatter = true}}, lua_ls = config["get-lua-ls-config"](), nixd = {}, racket_langserver = {}, rubocop = {}, rust_analyzer = {settings = {["rust-analyzer"] = {cargo = {autoreload = true}, checkOnSave = true, diagnostics = {disabled = {"unresolved-proc-macro"}, enable = true}, procMacro = {enable = true}}}}, solargraph = {init_options = {formatting = false}}, tailwindcss = {root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts"), single_file_support = false}, ts_ls = config["get-ts-ls-config"](), yamlls = {}}
end
config.lsp_servers = _3_
plugin.config = function()
  vim.keymap.set("n", "<leader>df", config.toggle_autoformat)
  vim.api.nvim_create_user_command("LspInfoV", "vert botright checkhealth vim.lsp", {})
  for name, options in pairs(config.lsp_servers()) do
    _G._SetupLspServer(name, options)
  end
  config.setup_file_autoformat(config.format_on_save_ft)
  local function virtual_text_prefix(diag)
    if (diag.severity == vim.diagnostic.severity.ERROR) then
      return " "
    elseif (diag.severity == vim.diagnostic.severity.WARN) then
      return " "
    else
    end
    return "\226\150\160 "
  end
  return vim.diagnostic.config({float = {source = true}, severity_sort = true, signs = true, underline = true, virtual_text = {prefix = virtual_text_prefix}})
end
config.on_lsp_attached = function(client, bufnr)
  local opts = {buffer = bufnr, noremap = true, silent = true}
  local function _5_()
    return vim.lsp.buf.hover({border = "single"})
  end
  vim.keymap.set("n", "K", _5_, opts)
  local function _6_()
    return vim.lsp.buf.rename()
  end
  vim.keymap.set("n", "grn", _6_, opts)
  vim.keymap.set("n", "<localleader>f", config.format_buffer, {noremap = true, silent = true})
  local function _7_()
    return vim.diagnostic.open_float()
  end
  vim.keymap.set("n", "<localleader>e", _7_, opts)
  local function _8_()
    return vim.diagnostic.goto_prev()
  end
  vim.keymap.set("n", "[d", _8_, opts)
  local function _9_()
    return vim.diagnostic.goto_next()
  end
  vim.keymap.set("n", "]d", _9_, opts)
  local function _10_()
    return vim.lsp.buf.code_action()
  end
  vim.keymap.set("n", "gra", _10_, opts)
  vim.keymap.set("n", "<leader>tu", "<cmd>LspRemoveUnused<cr>", opts)
  vim.keymap.set("n", "<leader>ta", "<cmd>LspAddMissingImports<cr>", opts)
  if client:supports_method("textDocument/inlayHints") then
    local filter = {bufnr = bufnr}
    vim.lsp.inlay_hint.enable(false, filter)
    local function toggle_inlay_hint()
      return vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(filter), {})
    end
    return vim.keymap.set("n", "<C-t>h", toggle_inlay_hint, opts)
  else
    return nil
  end
end
config["get-fennel-ls-config"] = function()
  local def = nfnl_config.default({["root-dir"] = ".", ["rtp-patterns"] = {"."}})
  return {settings = {["fennel-ls"] = {["extra-globals"] = "vim Snacks", ["fennel-path"] = def["fennel-path"], libraries = {nvim = true}, ["lua-version"] = "lua5.1", ["macro-path"] = def["fennel-macro-path"]}}}
end
config["get-lua-ls-config"] = function()
  return {settings = {Lua = {diagnostics = {globals = {"vim", "web"}}, hint = {enable = true}, workspace = {library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true, [(vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy")] = true}, maxPreload = 100000, preloadFileSize = 10000}}}}
end
config["get-hls-config"] = function()
  local function remove_unused_imports()
    local function _12_(cmd)
      return (cmd.title == "Remove all redundant imports")
    end
    return vim.lsp.buf.code_action({apply = true, context = {diagnostics = {}, only = {"quickfix"}}, filter = _12_})
  end
  return {commands = {LspRemoveUnused = {remove_unused_imports}}, settings = {languageServerHaskell = {completionSnippetsOn = true, hlintOn = true}}}
end
config["get-ts-ls-config"] = function()
  local function add_missing_import()
    return vim.lsp.buf.code_action({apply = true, context = {diagnostics = {}, only = {"source.addMissingImports.ts"}}})
  end
  local function remove_unused_imports()
    return vim.lsp.buf.code_action({apply = true, context = {diagnostics = {}, only = {"source.removeUnused.ts"}}})
  end
  return {capabilities = cap_disable_formatting(vim.lsp.protocol.make_client_capabilities()), commands = {LspAddMissingImports = {add_missing_import}, LspRemoveUnused = {remove_unused_imports}}, completions = {completeFunctionCalls = true}}
end
_G._SetupLspServer = function(name, opts, autoformat_ft)
  local options = (opts or {})
  local nvim_lsp = require("lspconfig")
  local cap = (options.capabilities or vim.lsp.protocol.make_client_capabilities())
  cap = blink.get_lsp_capabilities(cap)
  nvim_lsp[name].setup(vim.tbl_extend("force", {capabilities = cap, on_attach = config.on_lsp_attached}, options))
  if autoformat_ft then
    return config.setup_file_autoformat(autoformat_ft)
  else
    return nil
  end
end
config.setup_file_autoformat = function(fts)
  local function _14_(ev)
    return vim.api.nvim_create_autocmd("BufWritePre", {buffer = ev.buf, callback = config.run_auto_formatter})
  end
  return vim.api.nvim_create_autocmd("FileType", {callback = _14_, pattern = fts})
end
config.toggle_autoformat = function()
  config.is_autoformat_enabled = not config.is_autoformat_enabled
  if config.is_autoformat_enabled then
    return vim.notify("[Autoformat enabled]")
  else
    return vim.notify("[Autoformat disabled]")
  end
end
config.run_auto_formatter = function()
  if not config.is_autoformat_enabled then
    return 
  else
  end
  return config.format_buffer()
end
config.has_alt_formatter = function(client)
  return config.alt_formatters[client.name]
end
config.format_buffer = function()
  local buf = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({bufnr = buf})
  if (#clients == 0) then
    return 
  else
  end
  local is_formatted = false
  for _, client in ipairs(clients) do
    if config.has_alt_formatter(client) then
      config.alt_formatters[client.name]()
      is_formatted = true
    else
    end
  end
  if not is_formatted then
    return vim.lsp.buf.format({async = false})
  else
    return nil
  end
end
return plugin
