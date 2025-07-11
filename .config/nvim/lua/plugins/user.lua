---@type LazySpec
return {
  -- Alignin text
  { "kg8m/vim-simple-align", lazy = false },

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

  -- Flexoki colorscheme
  {
    "nuvic/flexoki-nvim",
    name = "flexoki",
  },
}
