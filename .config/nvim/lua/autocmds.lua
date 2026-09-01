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

-- nvim-treesitter 的 main 分支重写后已经没有 indent = { enable = true } 这个选项了，
-- 要自己把 indentexpr 挂上（NvChad 只负责 vim.treesitter.start 做高亮）。
autocmd("FileType", {
  callback = function(args)
    if vim.treesitter.get_parser(args.buf, nil, { error = false }) then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
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
