local overrides = require "configs.overrides"

return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      require "configs.conform"
    end,
  },
  {
    "Exafunction/windsurf.vim",
    event = "BufEnter",
    config = function()
      vim.keymap.set("i", "<M-j>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true, silent = true })
    end,
  },
  {
    "APZelos/blamer.nvim",
    lazy = false,
    config = function()
      vim.g.blamer_enabled = true
    end,
  },

  -- override plugin configs
  {
    -- mason 仓库已迁移到 mason-org（NvChad 也是按这个名字声明的）
    "mason-org/mason.nvim",
    opts = overrides.mason,
    config = function(_, opts)
      -- mason v2 不再认 ensure_installed，NvChad 也删掉了 :MasonInstallAll，
      -- 所以这里自己补回来，让 configs/overrides.lua 里的清单重新生效。
      local ensure = opts.ensure_installed or {}
      local setup_opts = vim.tbl_deep_extend("force", {}, opts)
      setup_opts.ensure_installed = nil
      require("mason").setup(setup_opts)

      vim.api.nvim_create_user_command("MasonInstallAll", function()
        if #ensure == 0 then
          return vim.notify("overrides.mason.ensure_installed is empty", vim.log.levels.WARN)
        end
        vim.cmd("MasonInstall " .. table.concat(ensure, " "))
      end, { desc = "Install everything in overrides.mason.ensure_installed" })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = overrides.treesitter,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = overrides.nvimtree,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = {
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden",
          "--glob=!.git/",
        },
      },
    },
  },

  {
    "alexghergh/nvim-tmux-navigation",
    lazy = false,
    config = function()
      require("nvim-tmux-navigation").setup {
        disable_when_zoomed = true,
        keybindings = {
          left = "<C-h>",
          down = "<C-j>",
          up = "<C-k>",
          right = "<C-l>",
          last_active = "<C-\\>",
          next = "<C-Space>",
        },
      }
    end,
  },
  {
    "ybian/smartim",
    lazy = false,
  },
  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {}
    end,
  },
  {
    "dhruvasagar/vim-open-url",
    lazy = false,
  },
  {
    "folke/which-key.nvim",
    enabled = false,
  },
}
