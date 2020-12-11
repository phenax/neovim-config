exec = vim.api.nvim_command
fn = vim.fn
o = vim.o
g = vim.g

g.mapleader = "\\"
g.maplocalleader = " "

g.noshowmode = true

require "settings"
require "packer-autoload"
require "plugins"

