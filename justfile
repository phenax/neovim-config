test:
  nvim --clean -c "set rtp+=$PWD" -c "lua dofile('$PWD/init.lua')"

