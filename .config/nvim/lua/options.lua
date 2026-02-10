require "nvchad.options"

local opt = vim.opt
local g = vim.g
local wo = vim.wo

-- hide cmd line
opt.cmdheight = 0

-- auto reload
opt.autoread = true

opt.exrc = false

-- relative line numbers
wo.relativenumber = true

-- fold method
opt.foldlevel = 99
opt.foldmethod = "indent"

-- snippets path
g.vscode_snippets_path = "./snippets"
