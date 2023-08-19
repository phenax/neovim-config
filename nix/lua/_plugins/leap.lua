local M = {}

function M.setup()
  vim.keymap.set({'n', 'i', 'v'}, '<c-b>', function ()
    require('leap').leap {
      target_windows = vim.tbl_filter(
        function (win) return vim.api.nvim_win_get_config(win).focusable end,
        vim.api.nvim_tabpage_list_wins(0)
      ),
    }

    -- Search only on current window
    -- require('leap').leap { target_windows = { vim.fn.win_getid() } }
  end)
end

return M
