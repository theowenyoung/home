require "nvchad.autocmds"

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Dotenv files are closer to shell assignments than INI syntax.
vim.filetype.add({
  filename = {
    [".env"] = "sh",
  },
  pattern = {
    [".env%..*"] = "sh",
  },
})

-- Highlight on yank
local highlight_group = augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = "*",
})

-- fix https://github.com/neovim/neovim/issues/21856
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  callback = function()
    vim.cmd "sleep 10m"
  end,
})
