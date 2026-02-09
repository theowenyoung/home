# CLAUDE.md - Neovim Config Reference

## Architecture

NvChad v2.0 based config. DO NOT modify files in `lua/core/` or `lua/plugins/` -- these are NvChad framework files. All user customization goes in `lua/custom/`.

## Config Entry Points

- `init.lua` - Main entry: loads core, sets mise PATH, bootstraps lazy.nvim
- `lua/custom/chadrc.lua` - Central config: theme (`onedark`), plugin list (`custom.plugins`), mappings (`custom.mappings`)
- `lua/custom/init.lua` - Editor options: cmdheight=0, relativenumber, fold=indent, autocommands
- `lua/custom/plugins.lua` - Custom plugin specs (NvPluginSpec[] format for lazy.nvim)
- `lua/custom/mappings.lua` - All custom keybindings (NvChad mapping table format)

## Key Files to Edit

| Task | File |
|------|------|
| Add/remove plugins | `lua/custom/plugins.lua` |
| Change keybindings | `lua/custom/mappings.lua` |
| Configure LSP servers | `lua/custom/configs/lspconfig.lua` |
| Configure formatters | `lua/custom/configs/conform.lua` |
| Override treesitter/mason/nvimtree | `lua/custom/configs/overrides.lua` |
| Change theme/UI | `lua/custom/chadrc.lua` |
| Custom highlights | `lua/custom/highlights.lua` |
| Editor options/autocommands | `lua/custom/init.lua` |
| Custom snippets | `snippets/` (VSCode format JSON) |

## NvChad Mapping Table Format

```lua
M.section_name = {
  n = {  -- normal mode
    ["<key>"] = { "action" or function, "description", opts = { ... } },
  },
  i = {},  -- insert mode
  v = {},  -- visual mode
  x = {},  -- visual block mode
  t = {},  -- terminal mode
}
```

Plugin-specific mappings need `plugin = true` in the section table.

## Plugin Spec Format (lazy.nvim via NvChad)

```lua
{
  "author/plugin-name",
  event = "BufEnter",           -- lazy load trigger
  lazy = false,                 -- or load immediately
  enabled = false,              -- disable plugin
  opts = overrides.section,     -- pass to plugin setup()
  config = function() ... end,  -- custom setup
}
```

## LSP Setup Pattern

Servers are configured in `lua/custom/configs/lspconfig.lua` by adding to the `servers` table. Each server gets `custom_on_attach` (disables hover) and `capabilities` from NvChad defaults. Special root_dir patterns:
- `ts_ls`: uses `package.json` (single_file_support=false)
- `denols`: uses `deno.json` / `deno.jsonc`

This prevents ts_ls and denols from conflicting in the same project.

## Conform.nvim Formatter Priority

Formatters are tried in order; first available one is used:
1. `prettier_from_project` - only if project has `.prettierrc` or prettier in `package.json`
2. `deno_fmt` - only if `deno.json`/`deno.jsonc` exists
3. `prettier` - global fallback

All skip `.min.js` files. Toggle with `:FormatToggle`.

## Important Customizations

- **Delete behavior**: `d/x/c/D` use black hole register by default. `<leader>d/x/c/D` cuts to system clipboard.
- **AI completion**: Windsurf/Codeium (`<M-j>` to accept), NOT Copilot (commented out).
- **Tmux integration**: `<C-h/j/k/l>` works across nvim windows and tmux panes.
- **Input method**: smartim auto-switches IME on mode change (useful for CJK input).
- **Auto format**: Dual setup - both `BufWritePre` autocommand (LSP) and conform.nvim `format_on_save`.

## Data Locations

- Plugin installs: `~/.local/share/nvim/lazy/`
- Mason installs: `~/.local/share/nvim/mason/`
- Theme cache: `vim.g.base46_cache` (usually `~/.local/share/nvim/base46_cache/`)
- Snippet path: `./snippets` (relative to nvim config dir)
