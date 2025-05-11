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
    -- 1. 项目特定的prettier（最高优先级）
    prettier_from_project = {
      -- 复制prettier的所有配置
      command = "prettier",
      -- 仅在项目根目录有.prettierrc文件时激活
      condition = function(self, ctx)
        -- 查找项目根目录（有.git或package.json的目录）
        local root_markers = { ".git", "package.json", "deno.json" }
        local root_dir = vim.fs.dirname(vim.fs.find(root_markers, {
          upward = true,
          path = ctx.filename,
          type = "file",
        })[1] or ".")

        -- 在项目根目录查找prettier配置文件
        local prettier_configs = { ".prettierrc", ".prettierrc.js", ".prettierrc.json" }
        for _, config in ipairs(prettier_configs) do
          if vim.fn.filereadable(root_dir .. "/" .. config) == 1 then
            return true
          end
        end
        return false
      end,
    },

    -- 2. deno_fmt（次高优先级）
    deno_fmt = {
      -- 仅在项目中有deno.json时激活
      condition = function(self, ctx)
        -- 查找包含deno.json的根目录
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
