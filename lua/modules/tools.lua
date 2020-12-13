local tools = {}

function tools.plugins(use)
  use 'metakirby5/codi.vim'
end

function tools.configure()
  --
end

function tools.init(use)
  tools.plugins(use)
  tools.configure()
end

return tools
