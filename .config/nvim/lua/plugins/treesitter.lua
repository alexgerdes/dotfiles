-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      -- Web
      "html",
      "css",
      "javascript",
      "json",
      -- Main
      "haskell",
      "java",
      "python",
      "rust",
      -- Low level
      "c",
      "make",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
