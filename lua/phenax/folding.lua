local M = { group = nil }

function M.initialize()
  M.group = vim.api.nvim_create_augroup('phenax/folding', { clear = true })
  M.configure()
  M.setup_force_reevaluation()
  M.setup_lsp_folding()
end

function M.configure()
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
  vim.opt.foldlevel = 50
  vim.opt.foldenable = false
  vim.opt.foldtext = ''
  vim.opt.foldcolumn = '0'
  vim.opt.fillchars:append({ fold = '-' })

  -- Code folding
  vim.keymap.set('n', '<S-Tab>', 'zR')
  vim.keymap.set('n', '<leader><Tab>', function() M.toggle_foldlevel() end, { silent = true })
end

-- Toggle foldlevel: all or none
function M.toggle_foldlevel()
  local max_level = 20
  local min_level = 1

  if vim.o.foldlevel >= max_level then
    vim.cmd [[normal! zM<CR>]]
    vim.o.foldlevel = min_level
  else
    vim.cmd [[normal! zR<CR>]]
    vim.o.foldlevel = max_level
  end
end

function M.setup_force_reevaluation()
  -- Hack to force fold re-evaluation and to use ts for all folding
  vim.api.nvim_create_autocmd('FileType', {
    group = M.group,
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
end

function M.setup_lsp_folding()
  -- Use lsp for folding if present
  vim.api.nvim_create_autocmd('LspAttach', {
    group = M.group,
    callback = function(args)
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client ~= nil and client:supports_method('textDocument/foldingRange') then
        local win = vim.api.nvim_get_current_win()
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
        vim.wo[win][0].foldmethod = 'expr'
      end
    end,
  })
end

return M
