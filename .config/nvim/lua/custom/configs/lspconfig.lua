local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities

local parent_lspconfig = require "lspconfig"

local servers = { "html", "cssls", "denols", "ts_ls", "clangd" }
-- "denols",

local custom_on_attach = function(client, bufnr)
  client.server_capabilities.hover = false
  on_attach(client, bufnr)
  -- custom stuff
end

for _, lsp in ipairs(servers) do
  local options = {
    on_attach = custom_on_attach,
    capabilities = capabilities,
  }
  if lsp == "ts_ls" then
    options.root_dir = parent_lspconfig.util.root_pattern "package.json"
    options.single_file_support = false
  end
  if lsp == "cssls" then
    options.settings = {
      css = { lint = { unknownAtRules = "ignore" } },
    }
  end
  if lsp == "denols" then
    options.root_dir = parent_lspconfig.util.root_pattern("deno.json", "deno.jsonc")
  end

  parent_lspconfig[lsp].setup(options)
end
