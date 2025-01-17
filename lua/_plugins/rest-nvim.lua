local M = {}
local plugin = {
  'rest-nvim/rest.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
  },

  ft = { 'http' },

  config = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'http',
      callback = M.setup,
    })
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'json',
      callback = function()
        vim.bo.formatexpr = ''
        vim.bo.formatprg = 'jq'
      end,
    })
  end
}

function M.setup()
  vim.keymap.set('n', '<CR>', '<cmd>Rest run<cr>', { buffer = true })
  -- vim.api.nvim_create_autocmd("User", {
  --   pattern = "RestResponsePre",
  --   callback = function() end,
  -- })
end

vim.g.rest_nvim = {
  custom_dynamic_variables = {
    -- foobarity = function()
    --   return '---------foo'
    -- end
  },
  request = {
    skip_ssl_verification = false,
    hooks = {
      set_content_type = true,
      user_agent = 'curl',
    },
  },
  response = {
    hooks = {
      decode_url = true,
      format = true,
    },
  },
  clients = {
    curl = {
      statistics = {
        { id = 'time_total',     winbar = 'time',              title = 'Time taken' },
        { id = 'num_redirects',  title = 'Number of redirects' },
        { id = 'size_download',  winbar = 'size',              title = 'Download size' },
        { id = 'speed_download', title = 'Download speed' },
      },
    },
  },
}

HTTP = {
  _ = function(response, client)
    HTTP.response = response
    HTTP.client = client
  end,

  json = function()
    return vim.json.decode(HTTP.response.body)
  end,

  updateJSON = function(fn)
    local newResp = fn(HTTP.json())
    HTTP.response.body = vim.json.encode(newResp)
  end,

  header = function(name)
    local h = HTTP.response.headers[name]
    if h == nil then return '' end
    if type(h) == 'string' then return h or '' end
    if type(h) == 'table' then return table.concat(h, '') end
    return vim.inspect(h or '')
  end,

  jsonPath = function(...)
    local value = HTTP.json()
    for _, key in ipairs({ ... }) do
      if value == nil then
        return nil
      end
      value = value[key]
    end
    return value
  end,

  setEnv = function(key, value)
    HTTP.client.global.set(key, value)

    --- @type table
    local env_lines = HTTP.withEnvFile('r', function(file)
      local lines = {}
      for line in file:lines() do
        if not string.match(line, '^' .. key .. '=') then
          table.insert(lines, line)
        end
      end
      return lines
    end)

    HTTP.withEnvFile('w', function(file)
      table.insert(env_lines, key .. '=' .. vim.inspect(value))
      file:write(table.concat(env_lines, '\n'))
    end)
  end,

  withEnvFile = function(mode, fn)
    local env_file = vim.b._rest_nvim_env_file or require 'rest-nvim.dotenv'.find_relevent_env_file()
    if not env_file then return end

    local handle = io.open(env_file, mode)
    if not handle then return end

    local result = fn(handle)
    handle:close()
    return result
  end
}

return plugin
