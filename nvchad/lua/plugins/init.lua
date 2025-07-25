return {
  -- In order to modify the `lspconfig` configuration:
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  -- Code formatting
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },

  -- TeX
  {
    "lervag/vimtex",
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_general_view = "open -a Skim"
      vim.g.vimtex_compiler_latexmk = {
        options = {
          "-pdf",
          '-pdflatex="pdflatex -shell-escape %O %S"',
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_view_general_viewer = "/Applications/Skim.app/Contents/SharedSupport/displayline -r"
      vim.g.vimtex_view_general_options = "@line @pdf @tex"
      vim.g.vimtex_syntax_enabled = 0
      vim.g.vimtex_quickfix_open_on_warning = 0
    end,
  },

  -- Alignin text
  { "kg8m/vim-simple-align", lazy = false },

  -- Language servers
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "lua-language-server",
        "stylua",
        "prettier",
        -- Haskell
        "haskell-language-server",
        -- Python
        "pyright",
        "black",
        "isort",
      },
      automatic_instalation = true,
    },
  },

  -- Tree-sitter syntax highlightning
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        -- Vim
        "vim",
        "lua",
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
      },
      auto_install = true,
      indent = { enable = true },
      highlight = { enable = true },
    },
  },

  -- Sessions
  {
    "Shatur/neovim-session-manager",
    event = "VimEnter",
    config = function()
      require("session_manager").setup {
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled, -- CurrentDir,
      }
    end,
  },

  -- Lazygit
  {
    "kdheepak/lazygit.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<CR>", desc = "Lazy Git" },
    },
  },

  -- -- AI - LLM
  -- {
  --   "David-Kunz/gen.nvim",
  --   lazy = false,
  --   opts = {
  --     -- model = "mistral:instruct",
  --     model = "qwen2.5-coder", -- "llama3.1:8b",
  --     display_mode = "float", -- The display mode. Can be "float" or "split" or "horizontal-split".
  --     show_prompt = true, -- Shows the prompt submitted to Ollama.
  --     show_model = true,
  --   },
  --   keys = {
  --     { "<leader>ww", "<cmd>Gen<CR>", desc = "LLM Prompt" },
  --   },
  -- },

  -- Nice notifications
  {
    "rcarriga/nvim-notify",
  },

  -- Use telescope for selections
  {
    "nvim-telescope/telescope-ui-select.nvim",
  },

  -- Thin column line
  {
    "lukas-reineke/virt-column.nvim",
    opts = {
      char = "│",
      virtcolumn = "80",
    },
    lazy = false,
  },

  -- Select surrounding stuff
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },
  -- Soft wrap at given column
  {
    "rickhowe/wrapwidth",
    lazy = false,
  },
  -- Notifcations and commands in a neat window
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    },
  },
  -- Interact with LLMs
  -- {
  --   "github/copilot.vim",
  --   lazy = false,
  -- },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
