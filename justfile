set positional-arguments

test_path:="nvim-test-config"

test *args:
  #!/usr/bin/env sh
  [ -L "$HOME/.config/{{test_path}}" ] || ln -sf "$PWD" "$HOME/.config/{{test_path}}";
  NVIM_APPNAME="{{test_path}}" nvim -c "lua vim.g.__phenax_test = true" "$@"

format:
  #!/usr/bin/env sh
  fnlfmt --fix `find . -iname *.fnl`

fennel_ls_setup:
  mkdir -p $HOME/.local/share/fennel-ls/docsets/
  curl -o $HOME/.local/share/fennel-ls/docsets/nvim.lua 'https://git.sr.ht/~micampe/fennel-ls-nvim-docs/blob/main/nvim.lua'
