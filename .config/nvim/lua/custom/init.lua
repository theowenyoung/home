-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
--

local opt = vim.opt
local g = vim.g
local wo = vim.wo

-- hide cmd line
opt.cmdheight = 0

-- auto reload
opt.autoread = true

opt.exrc = false
-- Make line numbers default

wo.relativenumber = true

-- folder method use treesitter
opt.foldlevel = 99
opt.foldmethod = "indent"
-- opt.foldexpr = "nvim_treesitter#foldexpr()"

-- snippets path
g.vscode_snippets_path = "./snippets"

local autocmd = vim.api.nvim_create_autocmd

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- auto format on save
local autoformat_group = vim.api.nvim_create_augroup("autoformat", { clear = true })
autocmd("BufWritePre", {
  group = autoformat_group,
  pattern = "*",
  command = "silent! lua vim.lsp.buf.format()",
})

-- fix https://github.com/neovim/neovim/issues/21856
-- https://www.reddit.com/r/neovim/comments/14bcfmb/nonzero_exit_code/
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.cmd "sleep 10m"
  end,
})
