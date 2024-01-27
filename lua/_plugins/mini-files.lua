local M = { show_preview = false }

local plugin = {
  'echasnovski/mini.files',
  version = '*',
  keys = {
    { '<localleader>nc', function() M.toggle_cwd() end, noremap = true, mode = 'n' },
    { '<localleader>nn', function() M.toggle_current() end, noremap = true, mode = 'n' },
  }
}

function plugin.config()
  require('mini.files').setup({
    options = {
      permanent_delete = true,
      use_as_default_explorer = true,
    },
    windows = {
      max_number = 5,
      preview = M.show_preview,
    },
    mappings = {
      close       = 'q',
      go_in       = '<C-l>',
      go_in_plus  = 'l',
      go_out      = 'h',
      go_out_plus = '<C-h>',
      reset       = '@',
      reveal_cwd  = '<BS>',
      synchronize = '<C-s>',
    },
  })

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

  M.lsp_integration()
end

function M.bind_extra_keys(map)
  local mini_files = require('mini.files')
  map({
    n = {
      -- Change directory
      ['<C-c>'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        print(":cd " .. path)
        vim.notify(":cd " .. path, vim.log.levels.INFO, { title = "mini.files" })
        vim.fn.chdir(path)
      end,

      -- Toggle preview
      ['<C-p>'] = function()
        M.show_preview = not M.show_preview
        mini_files.refresh({ windows = { preview = M.show_preview } })
      end,

      -- Refresh files
      ['R'] = function()
        mini_files.refresh({ content = { filter = function() return true end } })
      end,

      -- Open in external application
      ['<C-x>'] = function()
        local path = mini_files.get_fs_entry().path
        vim.cmd('sil !setsid xdg-open ' .. path)
        vim.notify("!xdg-open " .. path, vim.log.levels.INFO, { title = "mini.files" })
      end,

      -- Copy path to clipboard (absolute)
      ['<C-y>'] = function()
        local path = mini_files.get_fs_entry().path
        vim.cmd(':let @+="' .. path .. '"')
        vim.notify("Copied to clipboard: " .. path, vim.log.levels.INFO, { title = "mini.files" })
      end,
      -- Copy path to clipboard (relative)
      ['Y'] = function()
        local path, _ = mini_files.get_fs_entry().path:gsub(vim.fn.getcwd(), '.')
        vim.cmd(':let @+="' .. path .. '"')
        vim.notify("Copied to clipboard: " .. path, vim.log.levels.INFO, { title = "mini.files" })
      end,

      -- Telescope grep inside dir
      ['<C-f>'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        mini_files.close()
        require('telescope.builtin').live_grep({ search_dirs = {path}, prompt_title = 'Grep: ' .. path })
      end,
      -- Telescope find files inside dir
      ['<leader>f'] = function()
        local path = vim.fs.dirname(mini_files.get_fs_entry().path)
        mini_files.close()
        require('telescope.builtin').find_files({ search_dirs = {path}, prompt_title = 'Find: ' .. path })
      end,

      -- Weird key bindings workaround
      ['<C-k>'] = 'k',
      ['<C-j>'] = 'j',
      ['H'] = 'h',
      ['L'] = 'l',
      ['K'] = 'k',
      ['J'] = 'j',
      ['<localleader><Tab>'] = '<nop>',
      ['<C-i>'] = '<nop>',
      ['<C-o>'] = '<nop>',
    },
  })
end

function M.minifiles_toggle(...)
  local mini_files = require('mini.files')
  if not mini_files.close() then
    mini_files.open(...)
  end
end

function M.toggle_cwd()
  M.minifiles_toggle(nil, false)
end

function M.toggle_current()
  M.minifiles_toggle(vim.api.nvim_buf_get_name(0), true)
end

M.lsp_integration = function()
  vim.api.nvim_create_autocmd('User', {
    pattern = { 'MiniFilesActionRename' },
    callback = function(args)
      -- vim.lsp.buf.execute_command({
      --   command = 'workspace/didRenameFiles',
      --   arguments = {
      --     {
      --       files = {
      --         { oldUri = 'file://'..args.data.from, newUri = 'file://'..args.data.to },
      --       },
      --     },
      --   },
      -- })

      -- Typescript only
      if args.data.from:sub(-3) == '.ts' then 
        vim.lsp.buf.execute_command({
          command = '_typescript.applyRenameFile',
          arguments = {
            { sourceUri = args.data.from, targetUri = args.data.to },
          },
          title = ''
        })
      end
    end
  })
end

return plugin

-- TODO: LSP integration
