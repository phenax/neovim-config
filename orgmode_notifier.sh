#!/usr/bin/env sh

nvim -u NONE --noplugin --headless \
  -c "lua dofile(vim.fn.stdpath('config') .. '/orgmode_notifier.lua')"
