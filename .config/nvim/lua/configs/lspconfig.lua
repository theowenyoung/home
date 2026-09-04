require("nvchad.configs.lspconfig").defaults()

-- 删掉两个 NvChad 默认的 buffer 局部映射（本 autocmd 注册在 defaults() 之后，
-- 同一 LspAttach 事件按注册顺序触发，所以能删到 on_attach 刚建好的映射）
--   <leader>D  type definition -> 让位给我们的剪贴板剪切
--   <leader>ra NvRenamer       -> 它是 <leader>r 的前缀，留着会让 <leader>r
--                                 等 timeoutlen，且替换成 a 开头的词会误触发 rename
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    pcall(vim.keymap.del, "n", "<leader>D", { buffer = args.buf })
    pcall(vim.keymap.del, "n", "<leader>ra", { buffer = args.buf })
  end,
})

vim.lsp.config("ts_ls", {
  root_markers = { "package.json" },
  single_file_support = false,
})

vim.lsp.config("denols", {
  root_markers = { "deno.json", "deno.jsonc" },
})

vim.lsp.config("cssls", {
  settings = {
    css = { lint = { unknownAtRules = "ignore" } },
  },
})

vim.lsp.enable { "html", "cssls", "denols", "ts_ls", "clangd" }
