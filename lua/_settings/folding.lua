vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldlevel = 50
vim.opt.foldenable = false
vim.opt.foldtext = ''
vim.opt.foldcolumn = '0'
vim.opt.fillchars:append({ fold = '-' })

-- Hack to force fold re-evaluation and to use ts for all folding
vim.api.nvim_create_autocmd('FileType', {
  callback = function()
    if vim.o.filetype == 'org' then
      vim.opt_local.foldexpr = 'nvim_treesitter#foldexpr()'
    else
      vim.opt_local.foldexpr = vim.opt_local.foldexpr
    end
    vim.opt_local.foldlevel = 50
    vim.opt_local.foldenable = false
  end
})

-- Use lsp for folding if present
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client ~= nil and client:supports_method('textDocument/foldingRange') then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      vim.wo[win][0].foldmethod = 'expr'
    end
  end,
})
