-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "lua",
      "vim",
      "vimdoc",
      -- Web
      "html",
      "css",
      "javascript",
      "json",
      "svelte",
      "typescript",
      -- Main
      "haskell",
      "java",
      "python",
      "rust",
      "erlang",
      "elixir",
      "ocaml",
      "swift",
      -- Low level
      "c",
      "llvm",
      "make",
      "nasm",
      -- Other
      "dockerfile",
      -- add more arguments for adding more treesitter parsers
    },
  },
}
