set positional-arguments

test_path:="nvim-test-config"

test *args:
  #!/usr/bin/env sh
  [ -L "$HOME/.config/{{test_path}}" ] || ln -sf "$PWD" "$HOME/.config/{{test_path}}";
  NVIM_APPNAME="{{test_path}}" nvim -c "lua vim.g.__phenax_test = true" "$@"

format:
  stylua init.lua lua/**/*.lua

