local plugin = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    'fdschmidt93/telescope-egrepify.nvim',
  },
}

local M = { actions = {}, previewers = {} }

function plugin.config()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local builtin = require 'telescope.builtin'

  local keymaps = {
    ['<C-h>'] = actions.select_horizontal,
    ['<C-o>'] = M.actions.open_and_resume,
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
    pickers = {
      git_stash = {
        mappings = {
          i = {
            ['<C-f>'] = M.actions.show_git_stash_files,
          },
        },
      },
      buffers = {
        mappings = {
          i = {
            ['<C-d>'] = actions.delete_buffer,
          },
        },
      },
    },
    extensions = {
      egrepify = {},
    },
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

function M.actions.git_apply_stash_file(stash_id)
  local actions = require 'telescope.actions'
  local action_state = require 'telescope.actions.state'
  local utils = require 'telescope.utils'

  return function(prompt_bufnr)
    local picker = action_state.get_current_picker(prompt_bufnr)

    local selection = picker:get_multi_selection()
    if #selection == 0 then selection = { picker:get_selection() } end

    local files = {}
    for _, sel in ipairs(selection) do
      table.insert(files, sel[1])
    end
    local git_command = {
      'sh',
      '-c',
      'git --no-pager diff HEAD..' .. stash_id .. ' -- ' .. table.concat(files, ' ') .. ' | git apply -',
    }

    local _, ret, stderr = utils.get_os_command_output(git_command)
    if ret == 0 then
      print('Applied stash files from ' .. stash_id)
    else
      print('Error applying stash ' .. stash_id .. ': ' .. vim.inspect(stderr))
    end
    actions.close(prompt_bufnr)
  end
end

function M.actions.show_git_stash_files()
  local actions = require 'telescope.actions'
  local pickers = require 'telescope.pickers'
  local finders = require 'telescope.finders'
  local action_state = require 'telescope.actions.state'
  local telescope_config = require('telescope.config').values

  local selection = action_state.get_selected_entry()
  if selection == nil or selection.value == nil or selection.value == '' then return end

  local stash_id = selection.value

  local opts = {}
  local p = pickers.new(opts, {
    prompt_title = 'Files in ' .. stash_id,
    __locations_input = true,
    finder = finders.new_oneshot_job({
      'git',
      '--no-pager',
      'stash',
      'show',
      stash_id,
      '--name-only',
    }, opts),
    previewer = M.previewers.git_stash_file(stash_id, opts),
    sorter = telescope_config.file_sorter(opts),
    attach_mappings = function() -- (_, map)
      actions.select_default:replace(M.actions.git_apply_stash_file(stash_id))
      return true
    end,
  })
  p:find()
end

function M.previewers.git_stash_file(stash_id, opts)
  local putils = require 'telescope.previewers.utils'
  local previewers = require 'telescope.previewers'

  return previewers.new_buffer_previewer {
    title = 'Stash file preview',
    get_buffer_by_name = function(_, entry) return entry.value end,
    define_preview = function(self, entry, _)
      local cmd = { 'git', '--no-pager', 'diff', stash_id, '--', entry.value }
      putils.job_maker(cmd, self.state.bufnr, {
        value = entry.value,
        bufname = self.state.bufname,
        cwd = opts.cwd,
        callback = function(bufnr)
          if vim.api.nvim_buf_is_valid(bufnr) then putils.regex_highlighter(bufnr, 'diff') end
        end,
      })
    end,
  }
end

function M.actions.open_and_resume(prompt_bufnr)
  require('telescope.actions').select_default(prompt_bufnr)
  require('telescope.builtin').resume()
end

return plugin
