local M = {}

M.base46 = {
  theme = "sehsa",
  hl_add = {},
  hl_override = {},
  integrations = {},
  changed_themes = {},
  transparency = false,
  theme_toggle = { "sehsa", "sehsa" },
}

M.ui = {
  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  },

  telescope = { style = "bordered" }, -- borderless / bordered

  ------------------------------- nvchad_ui modules -----------------------------
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal/round
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal and round theme only
    separator_style = "default",
    order = { "mode", "file", "git", "%=", "diagnostics", "lsp", "cwd", "cursor" },
  },

  -- lazyload it when there are 1+ buffers
  tabufline = {
    enabled = true,
    lazyload = true,
    order = { "treeOffset", "buffers", "tabs", "btns" },
    modules = nil,
  },

  nvdash = {
    load_on_startup = false,

    header = {
      "⠀⠀   ⠀⢀⣤⣤⣤⣤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀    ",
      "⠀  ⠀ ⠀⢸⣿⣿⣿⣿⣿⣷⡀⠀⠀⠀⠀⠀⠀⠀    ",
      "    ⠀⠀⠘⠉⠉⠙⣿⣿⣿⣷⠀⠀⠀⠀⠀  ⠀  ⠀",
      "    ⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣧⠀⠀⠀⠀⠀    ⠀",
      "    ⠀⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣆⠀⠀⠀⠀    ⠀",
      "    ⠀⠀⠀⠀⠀⣼⣿⣿⣿⣿⣿⣿⡀⠀⠀⠀    ⠀",
      "    ⠀⠀⠀⠀⣴⣿⣿⣿⠟⣿⣿⣿⣷⠀⠀⠀⠀    ",
      "    ⠀⠀⠀⣰⣿⣿⣿⡏⠀⠸⣿⣿⣿⣇⠀⠀⠀    ",
      "    ⠀⠀⢠⣿⣿⣿⡟⠀⠀⠀⢻⣿⣿⣿⡆⠀⠀    ",
      "    ⠀⢠⣿⣿⣿⡿⠀⠀⠀⠀⠀⢿⣿⣿⣷⣤⡄    ",
      "    ⢀⣾⣿⣿⣿⠁⠀⠀⠀⠀⠀⠈⠿⣿⣿⣿⡇    ",
    },

    buttons = {
      { "  Find File", "Spc f f", "Telescope find_files" },
      { "󰈚  Recent Files", "Spc f o", "Telescope oldfiles" },
      { "󰈭  Find Word", "Spc f w", "Telescope live_grep" },
      { "  Bookmarks", "Spc m a", "Telescope marks" },
      { "  Themes", "Spc t h", "Telescope themes" },
      { "  Mappings", "Spc c h", "NvCheatsheet" },
    },
  },

  cheatsheet = { theme = "grid" }, -- simple/grid

  lsp = { signature = true },
}

M.term = {
  sizes = { sp = 0.2, vsp = 0.4 },
  float = {
    relative = "editor",
    row = 0.125,
    col = 0.125,
    width = 0.7,
    height = 0.5,
    border = "rounded",
  },
}

-- M.nvimtree = {
--   git = {
--     enable = true,
--   },
--
--   renderer = {
--     highlight_git = true,
--     icons = {
--       show = {
--         git = true,
--       },
--     },
--   },
--
--   view = {
--     adaptive_size = true,
--     width = {
--       padding = 1,
--       max = 20,
--     },
--     side = "right",
--   },
-- }

return M
