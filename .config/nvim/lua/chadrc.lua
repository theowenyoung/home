---@type ChadrcConfig
local M = {}

local highlights = require "highlights"

M.base46 = {
  theme = "vscode_light",
  theme_toggle = { "vscode_light", "vscode_dark" },

  hl_override = highlights.override,
  hl_add = highlights.add,
}

return M
