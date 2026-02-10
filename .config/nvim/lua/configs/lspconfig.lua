require("nvchad.configs.lspconfig").defaults()

-- Delete NvChad's default <leader>D mapping (type definition)
-- so our clipboard cut mapping works
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    pcall(vim.keymap.del, "n", "<leader>D", { buffer = args.buf })
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
