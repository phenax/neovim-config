test *args:
  nvim --clean -c "set rtp+=$PWD" -c "lua dofile('$PWD/init.lua')" {{args}}

format:
  stylua init.lua lua/**/*.lua

