vim.cmd [[autocmd BufRead,BufEnter *.astro set filetype=astro]]

vim.cmd [[autocmd BufRead,BufEnter *.bqn set filetype=bqn]]
vim.cmd [[autocmd BufRead,BufEnter *.ua set filetype=uiua]]

vim.cmd [[autocmd BufRead,BufEnter *.http set filetype=http]]

vim.cmd [[autocmd BufRead,BufEnter *.env,*.env.* setlocal filetype=sh conceallevel=2]]

vim.cmd [[autocmd BufRead,BufEnter *.ts,*.tsx setlocal conceallevel=2]]

vim.cmd [[autocmd BufRead,BufEnter *.curl set ft=sh]]
