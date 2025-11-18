local M = {}

M.treesitter = {
  ensure_installed = {
    "vim",
    "lua",
    "html",
    "css",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
    -- disable = {
    --   "python"
    -- },
  },
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    "stylua",

    -- web dev stuff
    "css-lsp",
    "html-lsp",
    "typescript-language-server",
    "deno",

    -- format
    "prettier",

    -- shell
    "shfmt",
    "shellcheck",

    -- rust
    "rust-analyzer",
  },
}

-- git support in nvimtree
M.nvimtree = {
  filters = {
    dotfiles = false, -- 显示隐藏文件（如 .env, .gitignore）
    git_ignored = false,
    custom = {
      "^.git$", -- 隐藏 .git 目录
      "^.DS_Store$", -- 隐藏 macOS 系统文件
    },
  },
  git = {
    enable = true,
    ignore = false,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
  view = {
    width = 40,
    preserve_window_proportions = true,
  },
}

return M
