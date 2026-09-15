---@type LazySpec
return {
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

  -- Auto dark mode
  {
    "f-person/auto-dark-mode.nvim",
    cond = function() return vim.loop.os_uname().sysname == "Darwin" and not vim.g.vscode end,
    opts = {
      set_dark_mode = function()
        vim.cmd [[colorscheme catppuccin-mocha]]
        vim.api.nvim_set_option_value("background", "dark", {})
      end,
      set_light_mode = function()
        vim.cmd [[colorscheme flexoki]]
        vim.api.nvim_set_option_value("background", "light", {})
      end,
      update_interval = 1000,
      fallback = "dark",
    },
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

  -- Soft wrap at given column
  {
    "rickhowe/wrapwidth",
    lazy = false,
  },

  -- Extend the AstroCommunity Noice spec to use nvim-notify as its notification backend.
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

  -- Conform for formatting
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        tex = { "tex-fmt" },
        haskell = { "floskell" },
      },
      formatters = {
        floskell = {
          command = "floskell",
        },
      },
    },
  },

  -- Local Flexoki colorscheme
  {
    "AstroNvim/astroui",
    lazy = false,
    priority = 1000,
    init = function()
      require("flexoki").setup {
        highlight_override = function(colors)
          return {
            NeoTreeTabActive = { bg = colors.bg, fg = colors.tx, bold = true },
            NeoTreeTabInactive = { bg = colors.bg2 },
            NeoTreeTabSeparatorActive = { fg = colors.bg, bg = colors.bg },
            NeoTreeTabSeparatorInactive = { fg = colors.bg2, bg = colors.bg2 },
            StatusLine = { fg = colors.tx, bg = colors.bg },
          }
        end,
      }
    end,
  },

  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.picker.layout = { backdrop = false }
      local on_show = opts.picker.on_show
      opts.picker.on_show = function(picker)
        if on_show then on_show(picker) end
        vim.schedule(function()
          local win = picker.preview.win.win
          if win and vim.api.nvim_win_is_valid(win) then
            vim.wo[win].winhighlight = vim.wo[win].winhighlight
              .. ",LineNr:SnacksPickerPreviewLineNr"
              .. ",CursorLineNr:SnacksPickerPreviewLineNr"
              .. ",SignColumn:SnacksPickerPreviewSignColumn"
              .. ",FoldColumn:SnacksPickerPreviewFoldColumn"
          end
        end)
      end
    end,
  },

  -- Markdown rendering, disabled for now, needs an update to work with treesitter and newer neovim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",

      -- see below for full list of optional dependencies 👇
    },
    opts = {
      workspaces = {
        {
          name = "Personal",
          path = "~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Personal",
        },
        {
          name = "Work",
          path = "~/Library/CloudStorage/OneDrive-Chalmers/Obsidian/Work",
        },
      },

      -- see below for full list of options 👇
    },
  },
}
