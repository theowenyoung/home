---@type ChadrcConfig
local M = {}

local highlights = require "highlights"

M.base46 = {
  theme = "onedark",
  theme_toggle = { "onedark", "one_light" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

return M
