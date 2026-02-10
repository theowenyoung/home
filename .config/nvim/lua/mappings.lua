require "nvchad.mappings"

local map = vim.keymap.set
local del = vim.keymap.del

-- Delete conflicting NvChad defaults
del("n", "<leader>x") -- NvChad: close buffer -> we use for clipboard cut
del("n", "<leader>e") -- NvChad: NvimTree focus -> we use for diagnostic float
del("i", "<C-j>")     -- NvChad: cursor move -> tmux navigation
del("i", "<C-k>")     -- NvChad: cursor move -> tmux navigation

local function termcodes(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

-- nvim tree grep in folder
local function grep_in()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()
  if not node then
    return
  end
  local path = node.absolute_path or vim.uv.cwd()
  if node.type ~= "directory" and node.parent then
    path = node.parent.absolute_path
  end
  require("telescope.builtin").live_grep {
    search_dirs = { path },
    prompt_title = string.format("Grep in [%s]", vim.fs.basename(path)),
  }
end

-- ============================================================
-- Normal mode
-- ============================================================
map("n", ";", ":", { desc = "Command mode", nowait = true })
map("n", "<Space>X", ":%bd|e#<CR>", { desc = "Close all buffers but this one" })
map("n", "qq", ":q<CR>", { desc = "Quit" })
map("n", "<Leader>w", ":w<CR>", { desc = "Save file" })
map("n", "<D-s>", ":w<CR>", { desc = "Save file" })
map("n", "<BS>", "<C-^>", { desc = "Toggle last buffer" })
map("n", "<Leader>be", ":%bd|e#<CR>", { desc = "Close all other buffers" })

-- Delete to black hole register by default; <leader> versions cut to clipboard
map("n", "x", [["_x]], { desc = "Delete not cut" })
map("n", "d", [["_d]], { desc = "Delete not cut" })
map("n", "c", [["_c]], { desc = "Change not cut" })
map("n", "D", [["_D]], { desc = "Delete not cut" })
map("n", "<leader>x", [["+x]], { desc = "Delete with cut" })
map("n", "<Leader>d", [["+d]], { desc = "Delete with cut" })
map("n", "<Leader>c", [["+c]], { desc = "Change with cut" })
map("n", "<Leader>D", [["+D]], { desc = "Delete with cut" })

map("n", "<Leader>s", ":%sno/", { desc = "Substitute exactly" })

-- Open parent directory in Finder
map("n", "<leader>o", function()
  local api = require("nvim-tree.api")
  local node = api.tree.get_node_under_cursor()
  if node then
    vim.cmd("!open " .. node.absolute_path:match "(.*)/[^/]*$")
  end
end, { desc = "Open in finder" })

-- Close buffer
map("n", "<Leader><BS>", function()
  require("nvchad.tabufline").close_buffer()
end, { desc = "Close buffer" })

-- LSP
map("n", "<leader>fm", function()
  vim.lsp.buf.format { async = true }
end, { desc = "LSP formatting" })

map("n", "<leader>e", function()
  vim.diagnostic.open_float()
end, { desc = "Show line diagnostics" })

map("n", "<leader>E", "<cmd>Telescope diagnostics<CR>", { desc = "Show all LSP errors" })

-- Telescope
map("n", "<C-A-o>", "<cmd>Telescope find_files hidden=true<CR>", { desc = "Find files" })
map("n", "<C-A-b>", "<cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("n", "<C-A-r>", "<cmd>Telescope resume<CR>", { desc = "Resume last results" })

-- Far
map("n", "<Leader>S", ":Farr<cr>", { desc = "Find and replace" })

-- Open URL
map("n", "gx", "<Plug>(open-url-browser)", { silent = true, desc = "Open URL" })

-- NvimTree grep in folder
map("n", "<C-A-n>", grep_in, { desc = "Search this folder" })

-- ============================================================
-- Visual/select mode (x)
-- ============================================================
map("x", "x", [["_x]], { desc = "Delete not cut" })
map("x", "d", [["_d]], { desc = "Delete not cut" })
map("x", "c", [["_c]], { desc = "Change not cut" })
map("x", "D", [["_D]], { desc = "Delete not cut" })
map("x", "<leader>x", [["+x]], { desc = "Delete with cut" })
map("x", "<Leader>d", [["+d]], { desc = "Delete with cut" })
map("x", "<Leader>c", [["+c]], { desc = "Change with cut" })
map("x", "<Leader>D", [["+D]], { desc = "Delete with cut" })
map("x", "<C-r>", [["hy:%s/<C-r>h//g<left><left>]], { desc = "Replace selected word" })
map("x", "<Leader>S", ":Farr<cr>", { desc = "Find and replace" })
map("x", "gx", "<Plug>(open-url-browser)", { silent = true, desc = "Open URL" })

-- ============================================================
-- Insert mode
-- ============================================================
map("i", "<C-s>", "<ESC>:w<CR>", { desc = "Save file" })
map("i", "<C-a>", "<ESC>^i", { desc = "Beginning of line" })
map("i", "<C-A-w>", "<ESC><C-w>", { desc = "Open window manager" })
map("i", "<C-A-o>", "<ESC><cmd>Telescope find_files hidden=true<CR>", { desc = "Find files" })
map("i", "<C-A-b>", "<ESC><cmd>Telescope buffers<CR>", { desc = "Find buffers" })
map("i", "<C-A-r>", "<cmd>Telescope resume<CR>", { desc = "Resume last results" })

-- ============================================================
-- Terminal mode
-- ============================================================
map("t", "<C-A-w>", termcodes "<C-\\><C-N><C-w>", { desc = "Open window manager" })
map("t", "<C-h>", termcodes "<C-\\><C-N>" .. "<C-w>h", { desc = "Switch left window" })
map("t", "<C-j>", termcodes "<C-\\><C-N>" .. "<C-w>j", { desc = "Switch down window" })
map("t", "<C-k>", termcodes "<C-\\><C-N>" .. "<C-w>k", { desc = "Switch up window" })
map("t", "<C-l>", termcodes "<C-\\><C-N>" .. "<C-w>l", { desc = "Switch right window" })
map("t", "<C-n>", termcodes "<C-\\><C-N>" .. "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
map("t", "<C-A-o>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  require("telescope.builtin").find_files()
end, { desc = "Find files" })
map("t", "<C-A-b>", function()
  require("nvchad.term").toggle { pos = "sp", id = "htoggleTerm" }
  require("telescope.builtin").buffers()
end, { desc = "Find buffers" })
