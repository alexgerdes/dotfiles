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
    opts = {
      -- set_dark_mode = function() vim.api.nvim_set_option_value("background", "dark", {}) end,
      -- set_light_mode = function() vim.api.nvim_set_option_value("background", "light", {}) end,
      set_dark_mode = function() vim.cmd [[colorscheme catppuccin-mocha]] end,
      set_light_mode = function() vim.cmd [[colorscheme flexoki-dawn]] end,
      update_interval = 3000,
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

  -- Tinted colorscheme for base16 and base24 themes
  {
    "tinted-theming/tinted-vim",
  },

  -- Flexoki colorscheme
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
  },
}
