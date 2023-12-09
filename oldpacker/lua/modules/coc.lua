local utils = require 'utils'
local set = utils.set
local nmap = utils.nmap
local nmap_silent = utils.nmap_silent

local coc = {
  extensions = {
    'coc-actions',
    'coc-git',
    --'coc-import-cost',
    'coc-snippets',

    -- Languages
    'coc-tsserver',
    'coc-eslint',
    'coc-html',
    'coc-css',
    'coc-cssmodules',
    'coc-rls',
    'coc-vetur',
    'coc-json',
    'coc-python',
    --'coc-reason',
    --'coc-rust-analyzer',
    --'coc-flutter',
    --'coc-go',
  }
}

function coc.plugins(use)
  -- use 'ludovicchabant/vim-gutentags'
  use { 'neoclide/coc.nvim', branch = 'release' }

  g.coc_global_extensions = coc.extensions
end

function coc___show_documentation()
  if utils.isOneOf({'vim','help'}, vim.bo.filetype) then
    exec [[execute 'h '.expand('<cword>')]]
  else
    exec [[call CocActionAsync('doHover')]]
  end
end

function coc.configure()
  -- g.gutentags_enabled = 1
  set('tags', 'tags')
  set('path', '.')
  -- g['deoplete#enable_at_startup'] = 1

  -- Diagnostics
  nmap('K', ':lua coc___show_documentation()<cr>') -- type docs
  exec [[autocmd CursorHold * silent call CocActionAsync('highlight')]] -- error
  exec [[set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}]] -- statusline
  utils.nnoremap('<localleader>e', ':CocList diagnostics<CR>')

  -- Navigate errors
  nmap_silent('[d', '<Plug>(coc-diagnostic-prev)')
  nmap_silent(']d', '<Plug>(coc-diagnostic-next)')

  -- Actions
  nmap('<leader>rn', '<Plug>(coc-rename)') -- rename tag
  exec [[command! -nargs=? Fold :call CocAction('fold', <f-args>)]] -- Folding
  exec [[command! -nargs=0 Format :call CocAction('format')]] -- Format
  exec [[command! -nargs=0 OR :call CocAction('runCommand', 'editor.action.organizeImport')]] -- Reorganize imports
  nmap('<localleader>aa', ':CocCommand actions.open<CR>') -- Show code actions
  vim.api.nvim_set_keymap('i', '<c-space>', 'coc#refresh()', { silent = true, expr = true })

  -- Fix/Format code
  nmap('<localleader>f', ':CocCommand eslint.executeAutofix<CR>')
  nmap('<leader>mf', ':Format<CR>')
  nmap('<localleader>F', '<Plug>(coc-fix-current)')
  utils.xmap('<localleader>f', '<Plug>(coc-format-selected)')

  -- Code navigation
  nmap_silent('gd', '<Plug>(coc-definition)')
  nmap_silent('gy', '<Plug>(coc-type-definition)')
  nmap_silent('gi', '<Plug>(coc-implementation)')
  nmap_silent('gr', '<Plug>(coc-references)')

  g.coc_snippet_next = '<c-j>'
  g.coc_snippet_prev = '<c-k>'

  vim.api.nvim_set_keymap('i', '<C-j>', '<Plug>(coc-snippets-expand-jump)', {})
end

return coc
