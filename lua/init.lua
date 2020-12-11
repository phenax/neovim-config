local exec = vim.api.nvim_command
local fn = vim.fn
local o = vim.o
local g = vim.g

g.mapleader = "\\"
g.maplocalleader = " "

g.noshowmode = true

require "packer-autoload"
require "plugins"

