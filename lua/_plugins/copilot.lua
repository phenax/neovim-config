return {
  'github/copilot.vim',
  enabled = true,
  config = function()
    vim.g.copilot_filetypes = {
      gitcommit = true,
    }
    vim.g.copilot_enabled = false

    -- Extra key alongside Tab in case of the occasional conflict
    vim.keymap.set('i', '<C-Tab>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.keymap.set('n', '<leader>sm', function()
      if (vim.g.copilot_enabled) then
        vim.cmd [[Copilot disable]]
        print 'Copilot disabled'
        vim.g.copilot_enabled = false
      else
        vim.cmd [[Copilot enable]]
        print 'Copilot enabled'
        vim.g.copilot_enabled = true
      end
    end)
  end,
}

-- Tab, <C-Tab> => Accept
-- <M-]> => Next suggestion
-- <M-[> => Prev suggestion
-- <M-Right> => Next word
-- <M-C-Right> => Next line
