-- [nfnl] fnl/phenax/folding.fnl
local _local_1_ = require("phenax.utils.utils")
local not_nil_3f = _local_1_["not_nil?"]
local folding = {group = nil, ["max-level"] = 20, ["min-level"] = 1}
folding.initialize = function()
  folding.group = vim.api.nvim_create_augroup("phenax/folding", {clear = true})
  folding.configure()
  folding.setup_force_reevaluation()
  return folding.setup_lsp_folding()
end
folding.configure = function()
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
  vim.opt.foldlevel = 50
  vim.opt.foldenable = false
  vim.opt.foldtext = ""
  vim.opt.foldcolumn = "0"
  vim.opt.fillchars:append({fold = "-"})
  vim.keymap.set("n", "<S-Tab>", "zR")
  local function _2_()
    return folding.toggle_foldlevel()
  end
  return vim.keymap.set("n", "<leader><Tab>", _2_, {silent = true})
end
folding.toggle_foldlevel = function()
  if (vim.o.foldlevel >= folding["max-level"]) then
    vim.cmd("normal! zM<CR>")
    vim.o.foldlevel = folding["min-level"]
    return nil
  else
    vim.cmd("normal! zR<CR>")
    vim.o.foldlevel = folding["max-level"]
    return nil
  end
end
folding.setup_force_reevaluation = function()
  local function _4_()
    local fold_expr
    if (vim.o.filetype == "org") then
      fold_expr = "nvim_treesitter#foldexpr()"
    else
      fold_expr = vim.opt_local.foldexpr
    end
    vim.opt_local.foldexpr = fold_expr
    vim.opt_local.foldlevel = 50
    vim.opt_local.foldenable = false
    return nil
  end
  return vim.api.nvim_create_autocmd("FileType", {group = folding.group, callback = _4_})
end
folding.setup_lsp_folding = function()
  local function _6_(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if (not_nil_3f(client) and client:supports_method("textDocument/foldingRange")) then
      local win_id = vim.api.nvim_get_current_win()
      vim.wo[win_id][0]["foldexpr"] = "v:lua.vim.lsp.foldexpr()"
      vim.wo[win_id][0]["foldmethod"] = "expr"
      return nil
    else
      return nil
    end
  end
  return vim.api.nvim_create_autocmd("LspAttach", {group = folding.group, callback = _6_})
end
return folding
