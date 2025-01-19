set positional-arguments

test *args:
  nvim --clean -c "set rtp+=$PWD" -c "lua dofile('$PWD/init.lua')" "$@"

format:
  stylua init.lua lua/**/*.lua

