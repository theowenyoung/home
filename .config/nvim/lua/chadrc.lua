---@type ChadrcConfig
local M = {}

local highlights = require "highlights"

M.base46 = {
  theme = "catppuccin-latte",
  theme_toggle = { "catppuccin-latte", "catppuccin" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

return M
