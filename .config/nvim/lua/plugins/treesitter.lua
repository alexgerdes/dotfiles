-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  config = function(_, opts)
    local install = require "nvim-treesitter.install"
    local ts_utils = require "nvim-treesitter.utils"
    local version = ts_utils.ts_cli_version()

    if version then
      local major, minor = version:match "^(%d+)%.(%d+)"
      major = tonumber(major)
      minor = tonumber(minor)

      if major and minor then
        if major > 0 or minor >= 25 then
          install.ts_generate_args = { "generate", "--abi", tostring(vim.treesitter.language_version) }
        else
          install.ts_generate_args = { "generate", "--no-bindings", "--abi", tostring(vim.treesitter.language_version) }
        end
      end
    end

    require("nvim-treesitter.configs").setup(opts)
  end,
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
