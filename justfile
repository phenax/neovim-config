set positional-arguments

test *args:
  # Update rtp twice because lazy.nvim overrides rtp
  nvim --clean -u NONE -c "lua vim.g.__phenax_test = true" -c "set rtp^=$PWD" -c "lua dofile('$PWD/init.lua')" -c "set rtp^=$PWD" "$@"

test-other dir *args:
  #!/usr/bin/env bash
  vim_dir="$PWD"
  cd "{{dir}}"
  nvim --clean -u NONE -c "set rtp^=$vim_dir" -c "lua dofile('$vim_dir/init.lua')" -c "set rtp^=$vim_dir" "$@"

format:
  stylua init.lua lua/**/*.lua

