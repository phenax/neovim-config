local M = {
  show_preview = false,
  lsp_timeout = 10000,
}

local plugin = {
  'echasnovski/mini.files',
  version = '*',
  keys = {
    { '<localleader>nc', function() M.toggle_cwd() end,     noremap = true, mode = 'n' },
    { '<localleader>nn', function() M.toggle_current() end, noremap = true, mode = 'n' },
  },
}

function plugin.config()
  require('mini.files').setup {
    options = {
      permanent_delete = true,
      use_as_default_explorer = true,
    },
    windows = {
      max_number = 5,
      preview = M.show_preview,
    },
    mappings = {
      close = 'q',
      go_in = '<C-l>',
      go_in_plus = 'L',
      go_out = 'H',
      go_out_plus = '<C-h>',
      reset = '@',
      reveal_cwd = '<BS>',
      synchronize = '<C-s>',
    },
  }

  M.init_event_handlers()
end

function M.bind_extra_keys(map)
  local mini_files = require 'mini.files'
  map {
    n = {
      -- Change directory
      ['<C-c>'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        print(':cd ' .. path)
        vim.notify(':cd ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
        vim.fn.chdir(path)
      end,

      -- Toggle preview
      ['<C-p>'] = function()
        M.show_preview = not M.show_preview
        mini_files.refresh { windows = { preview = M.show_preview } }
      end,

      -- Refresh files
      ['R'] = function()
        mini_files.refresh { content = { filter = function() return true end } }
      end,

      -- Open in external application
      ['<C-x>'] = function()
        local path = mini_files.get_fs_entry().path
        vim.cmd('sil !setsid xdg-open ' .. path)
        vim.notify('!xdg-open ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
      end,

      -- Copy path to clipboard (absolute)
      ['<C-y>'] = function()
        local path = mini_files.get_fs_entry().path
        vim.cmd(':let @+="' .. path .. '"')
        vim.notify('Copied to clipboard: ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
      end,
      -- Copy path to clipboard (relative)
      ['Y'] = function()
        local path = vim.fn.fnamemodify(mini_files.get_fs_entry().path, ':~:.')
        vim.cmd(':let @+="' .. path .. '"')
        vim.notify('Copied to clipboard: ' .. path, vim.log.levels.INFO, { title = 'mini.files' })
      end,

      -- Telescope grep inside dir
      ['<C-f>'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        mini_files.close()
        require('telescope.builtin').live_grep { search_dirs = { path }, prompt_title = 'Grep: ' .. path }
      end,
      -- Telescope find files inside dir
      ['<leader>f'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        mini_files.close()
        require('telescope.builtin').find_files { search_dirs = { path }, prompt_title = 'Find: ' .. path }
      end,

      -- Weird key bindings workaround
      ['<C-k>'] = 'k',
      ['<C-j>'] = 'j',
      -- ['H'] = 'h',
      -- ['L'] = 'l',
      -- ['K'] = 'k',
      -- ['J'] = 'j',
      ['<localleader><Tab>'] = '<nop>',
      ['<C-i>'] = '<nop>',
      ['<C-o>'] = 'L',
    },
  }
end

M.init_event_handlers = function()
  -- Bind keys to mini.files buffer
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
      M.bind_extra_keys(function(mappings)
        if args.data == nil or args.data.buf_id == nil then return end
        for mode, mode_map in pairs(mappings) do
          for k, v in pairs(mode_map) do
            vim.keymap.set(mode, k, v, { noremap = true, buffer = args.data.buf_id })
          end
        end
      end)
    end,
  })

  -- Handle on rename/move
  vim.api.nvim_create_autocmd('User', {
    pattern = { 'MiniFilesActionRename', 'MiniFilesActionMove' },
    callback = function(args)
      for _, client in ipairs(vim.lsp.get_clients()) do
        M.handle_lsp_rename(client, args)
      end
    end,
  })
end

function M.minifiles_toggle(...)
  local mini_files = require 'mini.files'
  if not mini_files.close() then mini_files.open(...) end
end

function M.toggle_cwd() M.minifiles_toggle(nil, false) end

function M.toggle_current()
  local path = vim.api.nvim_buf_get_name(0)
  while vim.loop.fs_stat(path) == nil do
    path = vim.fs.dirname(path)
  end
  M.minifiles_toggle(path, true)
end

local function get_path(obj, path)
  local current = obj
  for _, key in ipairs(path) do
    if current[key] == nil then return nil end
    current = current[key]
  end
  return current
end

function M.handle_lsp_rename(client, args)
  if get_path(client, { 'server_capabilities', 'workspace', 'fileOperations', 'willRename' }) == nil then return end

  local success, resp = pcall(client.request_sync, 'workspace/willRenameFiles', {
    files = {
      {
        oldUri = vim.uri_from_fname(args.data.from),
        newUri = vim.uri_from_fname(args.data.to),
      },
    },
  }, M.lsp_timeout)

  if success and resp and resp.result ~= nil then
    vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
  end
end

return plugin
