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
  end
}

function M.setup()
  vim.keymap.set('n', '<CR>', '<cmd>Rest run<cr>', { buffer = true })
end

vim.g.rest_nvim = {
  custom_dynamic_variables = {
    -- foobarity = function()
    --   return "---------foo"
    -- end
  },
  request = {
    skip_ssl_verification = false,
    hooks = {
      set_content_type = true,
      user_agent = "curl",
    },
  },
  clients = {
    curl = {
      statistics = {
        { id = "time_total",     winbar = "time",              title = "Time taken" },
        { id = "num_redirects",  title = "Number of redirects" },
        { id = "size_download",  winbar = "size",              title = "Download size" },
        { id = "speed_download", title = "Download speed" },
      },
    },
  },
}

-- TODO: API to update .env file
HTTP = {
  _ = function(response)
    HTTP.response = response
  end,

  json = function()
    return vim.json.decode(HTTP.response.body)
  end,

  updateJSON = function(response, fn)
    local newResp = fn(HTTP.json())
    response.body = vim.json.encode(newResp)
  end,

  header = function(name)
    local h = response.headers[name]
    if type(h) == "string" then return h end
    if type(h) == "table" then return table.concat(h, "") end
    return vim.inspect(h)
  end,

  path = function(...)
    local value = HTTP.json()
    for _, key in ipairs({ ... }) do
      if value == nil then
        return nil
      end
      value = value[key]
    end
    return value
  end,
}

return plugin
