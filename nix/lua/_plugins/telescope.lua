return {
  setup = function()
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

    -- Search inside current buffer
    vim.keymap.set('n', '<C-_>', builtin.current_buffer_fuzzy_find) -- Ctrl + /
  end
}
