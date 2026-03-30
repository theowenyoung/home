local conform = require "conform"
conform.setup {
  formatters_by_ft = {
    javascript = { "prettier_from_project" },
    typescript = { "prettier_from_project" },
    javascriptreact = { "prettier_from_project" },
    typescriptreact = { "prettier_from_project" },
    vue = { "prettier_from_project" },
    css = { "prettier_from_project" },
    scss = { "prettier_from_project" },
    less = { "prettier_from_project" },
    html = { "prettier_from_project" },
    json = { "prettier_from_project" },
    jsonc = { "prettier_from_project" },
    yaml = { "prettier_from_project" },
    markdown = { "prettier_from_project" },
    lua = { "stylua" },
    sh = { "shfmt" },
  },
  formatters = {
    prettier_from_project = {
      command = "prettier",
      args = { "--stdin-filepath", "$FILENAME" },
      range_args = function(self, ctx)
        return { "--stdin-filepath", "$FILENAME", "--range-start", "$RANGE_START", "--range-end", "$RANGE_END" }
      end,
      stdin = true,
      cwd = require("conform.util").root_file {
        ".prettierrc",
        ".prettierrc.json",
        ".prettierrc.yml",
        ".prettierrc.yaml",
        ".prettierrc.js",
        "prettier.config.js",
        "package.json",
      },
      condition = function(self, ctx)
        if ctx.filename:match "%.min%.js$" then
          return false
        end
        local root_markers = { ".git", "package.json", "deno.json" }
        local root_dir = vim.fs.dirname(vim.fs.find(root_markers, {
          upward = true,
          path = ctx.filename,
          type = "file",
        })[1])
        if not root_dir then
          return false
        end
        local prettier_configs = {
          ".prettierrc",
          ".prettierrc.js",
          ".prettierrc.json",
          ".prettierrc.yml",
          ".prettierrc.yaml",
          "prettier.config.js",
          "package.json",
        }
        for _, config in ipairs(prettier_configs) do
          local config_path = root_dir .. "/" .. config
          if vim.fn.filereadable(config_path) == 1 then
            if config == "package.json" then
              local ok, package_json = pcall(vim.fn.readfile, config_path)
              if ok then
                local content = table.concat(package_json, "\n")
                if content:match '"prettier"' then
                  return true
                end
              end
            else
              return true
            end
          end
        end
        return false
      end,
    },
    stylua = {},
    shfmt = {
      args = { "-i", "2", "-ci" },
    },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  debug = true,
}
vim.api.nvim_create_user_command("FormatToggle", function()
  conform.config.format_on_save.enabled = not conform.config.format_on_save.enabled
  print("Format on save: " .. tostring(conform.config.format_on_save.enabled))
end, { desc = "Toggle format on save" })
