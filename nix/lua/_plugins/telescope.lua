local M = {}

function M.setup()
  local telescope = require('telescope')
  local actions = require('telescope.actions')
  local builtin = require('telescope.builtin')

  local function open_and_resume(prompt_bufnr)
    actions.select_default(prompt_bufnr)
    builtin.resume()
  end

  telescope.setup {
    defaults = {
      prompt_prefix = ' λ ',
      sorting_strategy = 'ascending',
      layout_config = {
        width = 0.8,
        prompt_position = 'top',
        preview_cutoff = 120,
      },
      color_devicons = true,
      use_less = true,

      mappings = {
        n = {
          ['<C-d>'] = actions.delete_buffer,
          ['<C-o>'] = open_and_resume,
        },
        i = {
          ['<C-d>'] = actions.delete_buffer,
          ['<C-o>'] = open_and_resume,
        }
      },
    },
  }

  -- Search
  vim.keymap.set('n', '<c-f>', builtin.live_grep)

  -- Fuzzy file finder
  if vim.fn.filereadable('.git') == 1 then
    vim.keymap.set('n', '<leader>f', function() builtin.git_files({ show_untracked = true }) end)
  else
    vim.keymap.set('n', '<leader>f', builtin.find_files)
  end

  -- Resume last telescope search
  vim.keymap.set('n', '<leader>tr', builtin.resume)

  -- Set buffer file type
  vim.keymap.set('n', '<leader>cf', builtin.filetypes)

  -- Search through buffers
  vim.keymap.set('n', '<localleader>b', builtin.buffers)

  -- (Ctrl + /) Search inside current buffer
  vim.keymap.set('n', '<C-_>', builtin.current_buffer_fuzzy_find)

  -- Git branches
  vim.keymap.set('n', '<localleader>gbb', require'telescope.builtin'.git_branches)

  -- M.setup_theme()
end

function M.setup_theme()
  -- local bg = '#0f0c19'
  local bgfaded = '#110f1b'
  local bgfaded2 = '#1a1824'
  local accent = '#4e3aA3'

  local blend = function(c)
    return 'guibg=' .. c .. ' guifg=' .. c
  end

  updateScheme({
    'TelescopeNormal guibg=' .. bgfaded,
    'TelescopeBorder ' .. blend(bgfaded),

    'TelescopePreviewNormal guibg=' .. bgfaded,
    'TelescopePreviewTitle guibg=' .. accent .. ' guifg=#ffffff',

    'TelescopeResultsTitle ' .. blend(bgfaded),

    'TelescopePromptNormal guibg=' .. bgfaded2,
    'TelescopePromptTitle guibg=' .. accent .. ' guifg=#ffffff',
    'TelescopePromptBorder ' ..  blend(bgfaded2),
    'TelescopePromptPrefix guibg=' .. bgfaded2,
  })
end

return M

