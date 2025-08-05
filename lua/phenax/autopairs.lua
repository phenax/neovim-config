local autopairs = {
  excluded_filetypes = {
    'snacks_picker_input',
    'oil',
  },
  pairs = {
    ['('] = ')',
    ['['] = ']',
    ["{"] = "}",
    ["<"] = ">",
    ['"'] = '"',
    ['`'] = '`',
    ["'"] = "'",
  }
}

function autopairs.initialize()
  vim.api.nvim_create_autocmd('FileType', {
    pattern = '*',
    group = vim.api.nvim_create_augroup('phenax/autopairs', { clear = true }),
    callback = function(opts)
      if autopairs.is_disabled_ft(opts.buf) then return end

      for key, value in pairs(autopairs.pairs) do
        local keys = key .. value .. string.rep('<Left>', string.len(value))
        vim.keymap.set('i', key, keys, { buffer = true })
        -- TODO: consider disabling if recording macro `vim.fn.reg_recording() ~= ""`
      end
    end,
  })
end

function autopairs.is_disabled_ft(buf)
  local ft = vim.api.nvim_get_option_value('filetype', { buf = buf or 0 })
  return vim.tbl_contains(autopairs.excluded_filetypes, ft)
end

return autopairs
