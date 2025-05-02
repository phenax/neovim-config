local M = { actions = {}, previewers = {} }

local plugin = {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'fdschmidt93/telescope-egrepify.nvim',
  },
  keys = {
    { mode = 'n', '<c-f>',            '<cmd>Telescope egrepify<cr>' },
    { mode = 'n', '<leader>f' },
    { mode = 'n', '<leader>tr',       '<cmd>Telescope resume<cr>' },
    { mode = 'n', '<leader>tp',       '<cmd>Telescope pickers<cr>' },
    { mode = 'n', '<leader>cf',       '<cmd>Telescope filetypes<cr>' },
    { mode = 'n', '<leader>bb',       function() M.buffer_picker() end },
    { mode = 'n', '<C-_>',            '<cmd>Telescope current_buffer_fuzzy_find<cr>' },
    { mode = 'n', '<localleader>gbb', '<cmd>Telescope git_branches<cr>' },
    { mode = 'n', '<localleader>gbs', '<cmd>Telescope git_stash<cr>' },
    { mode = 'n', 'z=',               '<cmd>Telescope spell_suggest<cr>' },
    { mode = 'n', '<leader>xx',       '<cmd>Telescope diagnostics<cr>' },
  },
  cmd = { 'Telescope' },
}

function plugin.config()
  local telescope = require 'telescope'
  local actions = require 'telescope.actions'
  local builtin = require 'telescope.builtin'

  local common_keymaps = {
    ['<C-h>'] = actions.select_horizontal,
    ['<C-o>'] = M.actions.open_and_resume,
    ['<C-p>'] = require('telescope.actions.layout').toggle_preview,
  }

  telescope.setup {
    defaults = {
      prompt_prefix = ' λ  ',
      sorting_strategy = 'ascending',
      cache_picker = {
        num_pickers = 10,
      },
      borderchars = { '─', ' ', ' ', ' ', '─', '─', ' ', ' ' },
      layout_config = {
        width = { padding = 0 },
        height = { 0.7, min = 25 },
        anchor = 'S',
        anchor_padding = 0,
        prompt_position = 'top',
        preview_cutoff = 120,
      },
      color_devicons = true,
      use_less = true,
      preview = {
        treesitter = false,
      },

      mappings = {
        n = common_keymaps,
        i = common_keymaps,
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
end

function M.buffer_picker()
  require 'telescope.builtin'.buffers({
    select_current = true,
    sort_mru = true,
    -- sort_buffers = function(bufnr_a, bufnr_b) return bufnr_a < bufnr_b end,
  })
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
