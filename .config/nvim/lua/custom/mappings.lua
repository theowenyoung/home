local M = {}
local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- nvim tree grep in special folder
local function grep_in()
  -- print
  local node = require("nvim-tree.lib").get_node_at_cursor()
  if not node then
    return
  end
  local path = node.absolute_path or uv.cwd()
  if node.type ~= "directory" and node.parent then
    path = node.parent.absolute_path
  end
  require("telescope.builtin").live_grep {
    search_dirs = { path },
    prompt_title = string.format("Grep in [%s]", vim.fs.basename(path)),
  }
end

M.disabled = {
  n = {
    ["<C-j>"] = "",
    ["<C-k>"] = "",
  },

  i = {
    ["<C-j>"] = "",
    ["<C-k>"] = "",
  },
}

-- h(elllllll)
-- hello
-- general
M.general = {
  n = {
    [";"] = { ":", "command mode", opts = { nowait = true } },
    ["<Space>X"] = { ":%bd|e#<CR>", "close all buffers but this one" },
    ["C-A-w"] = { "<C-w>", "open window manager" },
    -- ["gx"] = { ":!open <c-r><c-a><CR>", "open url", opts = {
    --   silent = true,
    -- } },
    ["qq"] = { ":q<CR>", "quit" },
    ["<Leader>w"] = { ":w<CR>", "save filee" },
    ["<D-s>"] = { ":w<CR>", "save file" },
    ["<BS>"] = { "<C-^>", "toggle last buffer" },
    ["<Leader>be"] = { ":%bd|e#<CR>", "close all other buffers except the current one" },
    ["<leader>x"] = { [["+x]], "delete with cut" },
    ["<Leader>d"] = { [["+d]], "delete with cut" },
    ["<Leader>c"] = { [["+c]], "change with cut" },
    ["<Leader>D"] = { [["+D]], "delete with cut" },
    ["<Leader>s"] = { ":%sno/", "substitute exactly" },
    ["x"] = { [["_x]], "delete not cut" },
    ["d"] = { [["_d]], "delete not cut" },
    ["c"] = { [["_c]], "change not cut" },
    ["D"] = { [["_D]], "delete not cut" },
    -- close buffer + hide terminal buffer
    ["<leader><BS>"] = {
      function()
        require("nvchad.tabufline").close_buffer()
      end,
      "close buffer",
    },
  },
  x = {
    ["x"] = { [["_x]], "delete ../../ not cut" },
    ["d"] = { [["_d]], "delete not cut" },
    ["c"] = { [["_c]], "change not cut" },
    ["D"] = { [["_D]], "delete not cut" },
    ["<leader>x"] = { [["+x]], "delete with cut" },
    ["<Leader>d"] = { [["+d]], "delete with cut" },
    ["<Leader>c"] = { [["+c]], "change with cut" },
    ["<Leader>D"] = { [["+D]], "delete with cut" },
    ["<C-r>"] = { [["hy:%s/<C-r>h//g<left><left>]], "replace selected word" },
  },
  i = {
    ["<C-s>"] = { "<ESC>:w<CR>", "save file" },
    ["<C-a>"] = { "<ESC>^i", "beginning of line" },
    ["<C-A-w>"] = { "<ESC><C-w>", "open window manager" },
  },
  t = {
    ["<C-A-w>"] = { termcodes "<C-\\><C-N><C-w>", "open window manager" },
    ["<C-h>"] = { termcodes "<C-\\><C-N>" .. "<C-w>h", "switch left window" },
    ["<C-j>"] = { termcodes "<C-\\><C-N>" .. "<C-w>j", "switch down window" },
    ["<C-k>"] = { termcodes "<C-\\><C-N>" .. "<C-w>k", "switch up window" },
    ["<C-l>"] = { termcodes "<C-\\><C-N>" .. "<C-w>l", "switch right window" },
    ["<C-n>"] = { termcodes "<C-\\><C-N>" .. "<cmd> NvimTreeToggle <CR>", "switch right window" },
  },
}

M.open_url = {
  n = {
    ["gx"] = { "<Plug>(open-url-browser)", "open url", opts = {
      silent = true,
    } },
  },
  x = {
    ["gx"] = { "<Plug>(open-url-browser)", "open url", opts = {
      silent = true,
    } },
  },
}

M.far = {
  n = {
    ["<Leader>S"] = {
      ":Farr<cr>",
      "find and replace, substitute",
    },
  },
  x = {
    ["<Leader>S"] = {
      ":Farr<cr>",
      "find current word, and replace",
    },
  },
}
M.telescope = {
  i = {
    ["<C-A-o>"] = { "<ESC><cmd> Telescope find_files hidden=true <CR>", "find files" },
    ["<C-A-b>"] = { "<ESC><cmd> Telescope buffers <CR>", "find buffers" },
    ["<C-A-r>"] = { "<cmd> Telescope resume <CR>", "resume last results" },
  },
  n = {
    ["<C-A-o>"] = { "<cmd> Telescope find_files  hidden=true  <CR>", "find files" },
    ["<C-A-b>"] = { "<cmd> Telescope buffers <CR>", "find buffers" },
    ["<C-A-r>"] = { "<cmd> Telescope resume <CR>", "resume last results" },
  },
  t = {
    ["<C-A-o>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
        require("telescope.builtin").find_files()
      end,
      "find files",
    },
    ["<C-A-b>"] = {
      function()
        require("nvterm.terminal").toggle "horizontal"
        require("telescope.builtin").find_buffers()
      end,
      "find buffers",
    },
  },
}
M.lsp_config = {
  n = {
    ["<leader>fm"] = {
      function()
        vim.lsp.buf.format { async = true }
      end,
      "lsp formatting",
    },
    ["<leader>e"] = {
      function()
        vim.diagnostic.open_float()
      end,
      "show line diagnostics",
    },
    ["<leader>E"] = {
      "<cmd>Telescope diagnostics<CR>",
      "show all lsp error",
    },
  },
}

M.nvimtree = {
  plugin = true,
  n = {
    ["<C-A-n>"] = {
      grep_in,
      "search this folder",
    },
    ["<C-h>"] = { termcodes "<C-\\><C-N>" .. "<C-w>h", "switch left window" },
  },
}

-- more keybinds!
return M
