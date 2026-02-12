return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      format_on_save = true, -- enable or disable automatic formatting on save
      allow_filetypes = { -- enable format on save for specified filetypes only
        "lua",
      },
    },
  },
}
