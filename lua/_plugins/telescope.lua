local plugin = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'fdschmidt93/telescope-egrepify.nvim',
  },
}

function plugin.config()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local builtin = require 'telescope.builtin'

  local function open_and_resume(prompt_bufnr)
    actions.select_default(prompt_bufnr)
    builtin.resume()
  end

  local keymaps = {
    ['<C-d>'] = actions.delete_buffer,
    ['<C-o>'] = open_and_resume,
    ['<C-h>'] = actions.select_horizontal,
    ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
  }

  telescope.setup {
    defaults = {
      prompt_prefix = ' λ ',
      sorting_strategy = 'ascending',
      cache_picker = {
        num_pickers = 10,
      },
      layout_config = {
        width = 0.8,
        prompt_position = 'top',
        preview_cutoff = 120,
      },
      color_devicons = true,
      use_less = true,

      mappings = {
        n = keymaps,
        i = keymaps,
      },
    },
    extensions = {
      egrepify = {},
    }
  }

  -- Search
  vim.keymap.set('n', '<c-f>', '<cmd>Telescope egrepify<cr>', { silent = true })

  -- Fuzzy file finder
  if vim.fn.isdirectory '.git' == 1 or vim.fn.filereadable '.git' == 1 then
    vim.keymap.set(
      'n',
      '<leader>f',
      function()
        builtin.git_files {
          show_untracked = true,
        }
      end
    )
  else
    vim.keymap.set('n', '<leader>f', function()
      builtin.find_files {
        hidden = true,
      }
    end)
  end

  -- Resume last telescope search
  vim.keymap.set('n', '<leader>tr', builtin.resume)
  vim.keymap.set('n', '<leader>tp', builtin.pickers)

  -- File type
  vim.keymap.set('n', '<leader>cf', builtin.filetypes)

  -- Buffers
  vim.keymap.set('n', '<leader>bb', builtin.buffers)

  -- (Ctrl + /) Search inside current buffer
  vim.keymap.set('n', '<C-_>', builtin.current_buffer_fuzzy_find)

  -- Git branches
  vim.keymap.set('n', '<localleader>gbb', builtin.git_branches)
  vim.keymap.set('n', '<localleader>gbs', builtin.git_stash)

  -- Spell suggestions
  vim.keymap.set('n', 'z=', ':Telescope spell_suggest<CR>')
end

return plugin
