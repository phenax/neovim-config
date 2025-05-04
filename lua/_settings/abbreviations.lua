local function iabbr(name, expr, opts)
  local prefix = ''
  opts = opts or {}
  if opts.buffer then prefix = prefix .. '<buffer> ' end
  if opts.expr then prefix = prefix .. '<expr> ' end

  vim.cmd.inoreabbrev(prefix .. name .. '!', expr)
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function()
    -- Language
    iabbr('fn', "() => {}", { buffer = true })
    iabbr('lg', [[luaeval("require'phenax.utils'.js_console_log()")]], { buffer = true, expr = true })
    iabbr('lgc', [[luaeval("require'phenax.utils'.js_console_log_copied()")]], { buffer = true, expr = true })

    -- Api
    iabbr('typ', "type MyType = {}", { buffer = true })
    iabbr('comp', "export const MyComp: React.FC = () => {<CR>  return <div></div>;<CR>};", { buffer = true })
    iabbr('tbd', "expect(screen.findByRole()).toBeInTheDocument()", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua' },
  callback = function()
    -- Language
    iabbr('lg', "print(vim.inspect(obj))", { buffer = true })
    iabbr('fn', "function() end", { buffer = true })

    -- Api
    iabbr('aucmd', "vim.api.nvim_create_autocmd('Event', {})", { buffer = true })
    iabbr('key', "vim.keymap.set('n', 'key', action)", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'http' },
  callback = function()
    -- Language
    iabbr('get', "### \nGET http://", { buffer = true })
    iabbr('post', "### \nPOST http://<CR>Content-Type: application/json<CR><CR>{<CR>  \"key\": \"value\"<CR>}<CR>",
      { buffer = true })
    iabbr('put', "### \nPUT http://<CR>Content-Type: application/json<CR><CR>{<CR>  \"key\": \"value\"<CR>}<CR>",
      { buffer = true })
    iabbr('patch', "### \nPATCH http://<CR>Content-Type: application/json<CR><CR>{<CR>  \"key\": \"value\"<CR>}<CR>",
      { buffer = true })
    iabbr('del', "### \nDELETE http://", { buffer = true })

    -- Api
    iabbr('scr', '# @lang=lua\n> {%\nHTTP._(response, client)\n\n%}', { buffer = true })
  end,
})
