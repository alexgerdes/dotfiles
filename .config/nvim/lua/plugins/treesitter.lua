---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      auto_install = false,
      ensure_installed = {},
    },
  },
  {
    "romus204/tree-sitter-manager.nvim",
    dependencies = {}, -- tree-sitter CLI must be installed system-wide
    config = function()
      require("tree-sitter-manager").setup {
        -- Default Options
        -- ensure_installed = {}, -- list of parsers to install at the start of a neovim session
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
        -- border = nil, -- border style for the window (e.g. "rounded", "single"), if nil, use the default border style defined by 'vim.o.winborder'. See :h 'winborder' for more info.
        -- auto_install = false, -- if enabled, install missing parsers when editing a new file
        -- highlight = true, -- treesitter highlighting is enabled by default
        -- languages = {}, -- override or add new parser sources
        -- parser_dir = vim.fn.stdpath("data") .. "/site/parser",
        -- query_dir = vim.fn.stdpath("data") .. "/site/queries",
      }
    end,
  },
}
