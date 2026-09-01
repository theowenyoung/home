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
  -- 注：nvim-treesitter main 分支不再读 indent 选项；
  -- 缩进改在 autocmds.lua 里通过 indentexpr 启用
}

M.mason = {
  ensure_installed = {
    -- lua stuff
    "lua-language-server",
    -- 注：stylua 不走 mason。它的预编译二进制要 glibc >= 2.32，
    -- Debian 11 只有 2.31；改由 mise 提供（macOS 用预编译，Linux 用 cargo 源码编译）

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
    dotfiles = false,
    git_ignored = false,
    custom = {
      "^.git$",
      "^.DS_Store$",
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
