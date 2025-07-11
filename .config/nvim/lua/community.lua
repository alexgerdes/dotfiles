-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Color schemes
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- Languages
  { import = "astrocommunity.pack.lua" },
  -- CoPilot
  { import = "astrocommunity.completion.copilot-lua-cmp" },
}
