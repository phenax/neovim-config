local utils = require 'utils'
local nmap = utils.nmap
local nmap_options = utils.nmap_options

local ide = {
  lsp_format_on_save = {
    "haskell",
    "nix",
    "rust",
    "elm",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  lsp_servers = {
    rust_analyzer = {},
    tsserver = {},
    rnix = {},
    ocamlls = {},
    jsonls = {
      commands = {
        Format = {
          function()
            vim.lsp.buf.range_formatting({},{0,0},{vim.fn.line("$"),0})
          end
        }
      }
    },
    elmls = {},
    hls = {
      settings = {
        languageServerHaskell = {
          hlintOn = true,
        },
      },
    },
  },
}

function ide.plugins(use)
  use 'scrooloose/nerdcommenter'
  use 'Townk/vim-autoclose'
  use 'tpope/vim-surround'
  use 'wellle/targets.vim'
  --use 'easymotion/vim-easymotion'

  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/completion-nvim'

  -- Syntax
  use 'sheerun/vim-polyglot' -- All syntax highlighting
  use 'norcalli/nvim-colorizer.lua' -- Hex/rgb colors
  use 'tpope/vim-markdown' -- markdown
  use 'jtratner/vim-flavored-markdown' -- markdown

  -- Folding
  -- use 'wellle/context.vim'
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  --use 'preservim/tagbar'
  --use 'puremourning/vimspector'
end

function ide.on_lsp_attached(client, bufnr)
  local opts = { noremap=true, silent=true }

  -- Navigation
  nmap_options('<localleader>gd', '<Cmd>lua vim.lsp.buf.definition()<CR>', opts)
  nmap_options('<localleader>gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  nmap_options('<localleader>gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  nmap_options('K', '<Cmd>lua vim.lsp.buf.hover()<CR>', opts)

  -- Refactor actions
  nmap_options('<localleader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  nmap_options('<localleader>aa', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  nmap_options('<localleader>f', "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)

  -- Diagnostics
  nmap_options('<localleader>d', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
  nmap_options('[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  nmap_options(']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  nmap_options('<localleader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  -- nmap_options('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  -- nmap_options('<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  -- nmap_options('<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  -- nmap_options('<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  -- nmap_options('<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
end

-- Autoformatting hooks
is_autoformat_enabled = true;
function ide__lsp_toggle_autoformat()
  is_autoformat_enabled = not is_autoformat_enabled
  if is_autoformat_enabled then
    print "[Autoformat enabled]"
  else
    print "[Autoformat disabled]"
  end
end
function ide__lsp_on_save()
  if is_autoformat_enabled then
    vim.lsp.buf.formatting_sync(nil, 300)
  end
end

function ide.configure()
  g.context_enabled = 0

  -- Colorizer
  require'colorizer'.setup()

  -- Lsp
  local nvim_lsp = require 'lspconfig'
  for name, options in pairs(ide.lsp_servers) do
    nvim_lsp[name].setup(utils.merge({ on_attach = ide.on_lsp_attached }, options))
  end

  exec [[ autocmd ColorScheme * :lua require('vim.lsp.diagnostic')._define_default_signs_and_highlights() ]]

  -- Autoformatting
  nmap("<leader>df", ":lua ide__lsp_toggle_autoformat()<CR>")
  exec("autocmd FileType "
    ..table.concat(ide.lsp_format_on_save, ",")
    .." autocmd  BufWritePre <buffer> silent! :lua ide__lsp_on_save()")

  -- Completions
  exec [[autocmd BufEnter * lua require'completion'.on_attach()]]
  utils.set('completeopt', 'menuone,noinsert,noselect')
  g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy'}
  g.completion_matching_smart_case = 1
  exec [[
    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
  ]]

  -- Treesitter
  require'nvim-treesitter.configs'.setup {
    ensure_installed = "maintained", -- "all" | "maintained" | list of languages
    highlight = {
      enable = true,
    },
    -- rainbow = {
    --   enable = true,
    --   extended_mode = true,
    --   max_file_lines = 1000,
    -- },
    --custom_captures = { ["foo.bar"] = "Identifier", },
    --indent = { enable = true }
  }

  -- Symbols
  nmap('<localleader>ns', ':SymbolsOutline<cr>')
  g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false,
    position = 'right',
    keymaps = {
        close = "q",
        goto_location = "<CR>",
        focus_location = "o",
        hover_symbol = "K",
        rename_symbol = "r",
        code_actions = "a",
    },
    lsp_blacklist = {},
  }

  -- Open term in vim
  nmap('<localleader>tn', ':split term://node<cr>')
  nmap('<localleader>tt', ':split term://zsh<cr>')
  vim.api.nvim_set_keymap('t', '<Esc>', '<C-\\><C-n>', { noremap = true })

  -- Sessions
  nmap('<leader>sw', ':mksession! .vim.session<cr>')
  nmap('<leader>sl', ':source .vim.session<cr>')

  -- Code navigation/searching
  --nmap('<localleader>cm', ':TagbarToggle<cr>')
  --exec [[map <localleader> <Plug>(easymotion-prefix)]] -- <space>c
  nmap('<c-\\>', ':noh<CR>')

  nmap('<localleader>rw', '*:%s//<c-r><c-w>')

  -- Folding
  nmap('<S-Tab>', 'zR')
  nmap('zx', 'zo')
  nmap('zc', 'zc')
  nmap('zf', ':ContextToggle<CR>')

  -- Tagbar
  --exec [[autocmd FileType tagbar lua tagbarKeyBindings()]]
end

-- Bindings for tagbar
function tagbarKeyBindings()
  -- Scroll title to top
  nmap('m', '<enter>zt<C-w><C-w>')
end

return ide

