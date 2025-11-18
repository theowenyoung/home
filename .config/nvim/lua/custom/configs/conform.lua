local conform = require "conform"

conform.setup {
  formatters_by_ft = {
    -- Web开发相关，列出的顺序决定了优先级
    javascript = { "prettier_from_project", "deno_fmt", "prettier" },
    typescript = { "prettier_from_project", "deno_fmt", "prettier" },
    javascriptreact = { "prettier_from_project", "deno_fmt", "prettier" },
    typescriptreact = { "prettier_from_project", "deno_fmt", "prettier" },
    vue = { "prettier_from_project", "prettier" },
    css = { "prettier_from_project", "deno_fmt", "prettier" },
    scss = { "prettier_from_project", "prettier" },
    less = { "prettier_from_project", "prettier" },
    html = { "prettier_from_project", "prettier" },
    json = { "prettier_from_project", "deno_fmt", "prettier" },
    jsonc = { "prettier_from_project", "deno_fmt", "prettier" },
    yaml = { "prettier_from_project", "prettier" },
    markdown = { "prettier_from_project", "deno_fmt", "prettier" },

    -- Lua
    lua = { "stylua" },

    -- Shell
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
      -- 仅在项目根目录有prettier配置文件时激活
      condition = function(self, ctx)
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
          "package.json", -- package.json 中也可能有 prettier 配置
        }

        for _, config in ipairs(prettier_configs) do
          local config_path = root_dir .. "/" .. config
          if vim.fn.filereadable(config_path) == 1 then
            -- 如果是 package.json,检查是否有 prettier 字段
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

    -- 2. deno_fmt(次高优先级)
    deno_fmt = {
      condition = function(self, ctx)
        local deno_files = vim.fs.find({ "deno.json", "deno.jsonc" }, {
          upward = true,
          path = ctx.filename,
          type = "file",
        })
        return #deno_files > 0
      end,
    },

    -- 3. 全局prettier（最低优先级）
    prettier = {},

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

-- 可选：格式化切换命令
vim.api.nvim_create_user_command("FormatToggle", function()
  conform.config.format_on_save.enabled = not conform.config.format_on_save.enabled
  print("Format on save: " .. tostring(conform.config.format_on_save.enabled))
end, { desc = "Toggle format on save" })
