return {
  'github/copilot.vim',
  config = function()
    vim.g.copilot_filetypes = {
      gitcommit = true,
    }
    vim.g.copilot_enabled = true

    -- Extra key alongside Tab in case of the occasional conflict
    vim.keymap.set('i', '<C-Tab>', 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
  end,
}

-- Tab, <C-Tab> => Accept
-- <M-]> => Next suggestion
-- <M-[> => Prev suggestion
-- <M-Right> => Next word
-- <M-C-Right> => Next line
