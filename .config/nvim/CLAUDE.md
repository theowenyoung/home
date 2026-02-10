# CLAUDE.md - Neovim Config Reference

## Architecture

NvChad v2.5 based config. NvChad is loaded as a lazy.nvim plugin (`NvChad/NvChad` branch `v2.5`). There are no `lua/core/` or `lua/plugins/` framework directories -- all config lives directly under `lua/`.

## Config Entry Points

- `init.lua` - Main entry: sets mise PATH, bootstraps lazy.nvim, loads NvChad as plugin
- `lua/chadrc.lua` - Central config: theme (`onedark`), highlights
- `lua/options.lua` - Editor options: cmdheight=0, relativenumber, fold=indent
- `lua/autocmds.lua` - Autocommands: yank highlight, VimLeave fix
- `lua/mappings.lua` - All custom keybindings (`vim.keymap.set` format)
- `lua/plugins/init.lua` - Plugin specs (lazy.nvim format)

## Key Files to Edit

| Task | File |
|------|------|
| Add/remove plugins | `lua/plugins/init.lua` |
| Change keybindings | `lua/mappings.lua` |
| Configure LSP servers | `lua/configs/lspconfig.lua` |
| Configure formatters | `lua/configs/conform.lua` |
| Override treesitter/mason/nvimtree | `lua/configs/overrides.lua` |
| Change theme/UI | `lua/chadrc.lua` |
| Custom highlights | `lua/highlights.lua` |
| Editor options | `lua/options.lua` |
| Autocommands | `lua/autocmds.lua` |
| Custom snippets | `snippets/` (VSCode format JSON) |

## Mapping Format (v2.5)

Mappings use standard `vim.keymap.set`:

```lua
local map = vim.keymap.set
map("n", "<key>", action, { desc = "description" })
```

To remove NvChad defaults that conflict with custom mappings, use `vim.keymap.del`.

## Plugin Spec Format (lazy.nvim)

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

Servers are configured in `lua/configs/lspconfig.lua` using the new `vim.lsp.config()` + `vim.lsp.enable()` API. Special configurations:
- `ts_ls`: root_markers = `package.json` (single_file_support=false)
- `denols`: root_markers = `deno.json` / `deno.jsonc`

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
- **Auto format**: conform.nvim `format_on_save` only (no duplicate LSP BufWritePre autocmd).

## Data Locations

- Plugin installs: `~/.local/share/nvim/lazy/`
- Mason installs: `~/.local/share/nvim/mason/`
- Theme cache: `vim.g.base46_cache` (usually `~/.local/share/nvim/base46/`)
- Snippet path: `./snippets` (relative to nvim config dir)
