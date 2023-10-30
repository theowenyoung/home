local present, null_ls = pcall(require, "null-ls")

if not present then
  return
end

local b = null_ls.builtins

local sources = {

  -- webdev stuff
  b.formatting.deno_fmt.with {
    condition = function(utils)
      -- root has file deno.json, and not has file .prettierrc
      return utils.root_has_file "deno.json" and not utils.root_has_file ".prettierrc"
    end,
  },
  b.formatting.prettier.with {
    condition = function(utils)
      return utils.root_has_file ".prettierrc"
    end,
  },

  -- Lua
  b.formatting.stylua,

  -- Shell
  b.formatting.shfmt,
  b.diagnostics.shellcheck.with { diagnostics_format = "#{m} [#{c}]" },

  -- cpp
  -- b.formatting.clang_format,
  -- b.formatting.rustfmt,
}

null_ls.setup {
  debug = true,
  sources = sources,
}
