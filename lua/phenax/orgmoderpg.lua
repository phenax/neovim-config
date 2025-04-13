local M = {
  stats_config = {
    health_points = { label = "Health", icon = "💪", init = 0 },
    persistance = { label = "Persistance", icon = "🏋️", init = 0 },
    money = { label = "Money", icon = "💸", init = 0 },
    experience_points = { label = "Experience", icon = "🌍", init = 0 },
    assist_points = { label = "Assist", icon = "🤝", init = 0 },
    social_points = { label = "Social", icon = "👬", init = 0 },
    essence = { label = "Essense", icon = "🌿", init = 0 },
    productivity = { label = "Productivity", icon = "💼", init = 0 },
  },
  layout = {
    { "health_points",     "essence" },
    { "experience_points", "persistance" },
    { "assist_points",     "social_points" },
    { "productivity",      "money" },
  },
}

function M.evaluateScore(dir)
  dir = dir or vim.fn.expand '~/nixos/extras/notes/daily'
  local orgmode_api = require 'orgmode.api'

  local orgfiles = vim.iter(vim.fs.dir(dir))
      :filter(function(f, type) return type == 'file' and f:sub(-4) == '.org' end)
      :map(function(path) return orgmode_api.load(vim.fs.joinpath(dir, path)) end)
      :totable()

  local code = vim.iter(orgfiles)
      :map(function(f) return M.getCode(f) end)
      :join('\n')

  local env = setmetatable(M.scoreEvalEnv(), { __index = _G })
  local eval, err = load(code, 'scoring-eval', 't', env)

  if err ~= nil or eval == nil then return print(err or 'eval error') end
  eval()
  M.showStats(env.get_scores())
end

function M.getCode(file)
  return vim.iter(file._file:get_blocks())
      :filter(function(block) return block:get_language() == "lua" end)
      :map(function(block) return table.concat(block:get_content(), '\n') end)
      :join('\n')
end

function M.statsVisualChunk(score_keys, scores)
  return vim.iter(score_keys)
      :map(function(k)
        local p = M.stats_config[k]
        local score = scores[k]
        local hl = '@markup.strong'
        if score <= 0 then hl = 'WarningMsg' end
        return {
          { vim.fn.printf('%s %-14s', p.icon, p.label .. ':'), '' },
          { vim.fn.printf('%-10s', score),                     hl },
        }
      end)
      :flatten(1)
      :totable()
end

function M.showStats(scores)
  local contents = vim.iter(M.layout)
      :map(function(row)
        local row_chunks = M.statsVisualChunk(row, scores)
        table.insert(row_chunks, { '\n', '' })
        return row_chunks
      end)
      :flatten(1)
      :totable()
  vim.api.nvim_echo(contents, false, {})
end

function M.scoreEvalEnv()
  local scores = {}
  local updaters = {}
  for key, opts in pairs(M.stats_config) do
    scores[key] = opts.init
    updaters[key] = function(p)
      scores[key] = (scores[key] or 0) + p
    end
  end

  return vim.tbl_extend('force', {}, updaters, {
    get_scores = function() return scores end,
  })
end

return M
