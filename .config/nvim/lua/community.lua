-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  -- Color schemes
  { import = "astrocommunity.colorscheme.night-owl-nvim" },
  { import = "astrocommunity.colorscheme.everforest" },
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.colorscheme.github-nvim-theme" },
  -- Languages
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.haskell" },
  -- TeX
  { import = "astrocommunity.markdown-and-latex.vimtex" },
  -- VsCode
  { import = "astrocommunity.recipes.vscode" },
  -- CoPilot
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  -- Statusline
  { import = "astrocommunity.bars-and-lines.lualine-nvim" },
}
