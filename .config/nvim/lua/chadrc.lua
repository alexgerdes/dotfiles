local M = {}

local colors = {
  white = "#24292e",
  darker_black = "#f3f5f7",
  black = "#fafafa", --  nvim bg
  black2 = "#edeff1",
  one_bg = "#eaecee",
  one_bg2 = "#e1e3e5", -- StatusBar (filename)
  one_bg3 = "#d7d9db",
  grey = "#c7c9cb", -- Line numbers )
  grey_fg = "#bcbec0",
  grey_fg2 = "#b1b3b5",
  light_grey = "#a6a8aa",
  red = "#AF3029",
  baby_pink = "#CE5D97",
  pink = "#A02F6F",
  green = "#66800B",
  vibrant_green = "#879A39",
  nord_blue = "#4385BE",
  blue = "#205EA6",
  yellow = "#AD8301",
  sun = "#D0A215",
  purple = "#8265c0",
  dark_purple = "#5E409D",
  teal = "#519ABA",
  orange = "#BC5215",
  cyan = "#24837B",
  line = "#eaecee", -- for vertsplit
  statusline_bg = "#edeff1",
  lightbg = "#e1e3e5",
  pmenu_bg = "#3AA99F",
  folder_bg = "#6F6E69",
}

local dark = "ashes"
local light = "flexoki-light"

M.ui = {
  ------------------------------- base46 -------------------------------------
  -- hl = highlights
  hl_add = {},
  hl_override = {},
  changed_themes = {
    ["flexoki-light"] = {
      base_30 = colors,
      base_16 = {
        base00 = "#fafafa", -- Default bg
        base01 = "#edeff1", -- Lighter bg (status bar, line number, folding mks)
        base02 = "#e1e3e5", -- Selection bg
        base03 = "#d7d9db", -- Comments, invisibles, line hl
        base04 = "#c7c9cb", -- Dark fg (status bars)
        base05 = "#383d42", -- Default fg (caret, delimiters, Operators)
        base06 = "#2e3338", -- Light fg (not often used)
        base07 = "#24292e", -- Light bg (not often used)
        base08 = colors.red,
        base09 = colors.orange,
        base0A = colors.dark_purple,
        base0B = colors.green,
        base0C = colors.cyan,
        base0D = colors.blue,
        base0E = colors.yellow,
        base0F = colors.teal,
      },
    },
  },

  dark_theme = dark,
  light_theme = light,
  theme_toggle = { dark, light },
  theme = dark, -- default theme

  transparency = false,

  cmp = {
    icons = true,
    lspkind_text = true,
    style = "default", -- default/flat_light/flat_dark/atom/atom_colored
  },

  telescope = { style = "bordered" }, -- borderless / bordered

  ------------------------------- nvchad_ui modules -----------------------------
  statusline = {
    theme = "default", -- default/vscode/vscode_colored/minimal
    -- default/round/block/arrow separators work only for default statusline theme
    -- round and block will work for minimal theme only
    separator_style = "default",
    order = { "mode", "file", "git", "%=", "diagnostics", "lsp", "cwd", "cursor" },
    modules = {
      cursor = function()
        local icon = "%#St_pos_icon#%#St_pos_icon# "
        local sep = "%#St_pos_sep#█"
        local pos = "%#St_pos_text# %l:%c (%p%%) "
        return sep .. icon .. pos
      end,
      cwd = function()
        local icon = "%#St_cwd_icon#" .. "󰉋 "
        local name = vim.loop.cwd()
        name = "%#St_cwd_text#" .. " " .. (name:match "([^/\\]+)[/\\]*$" or name) .. " "
        return (vim.o.columns > 85 and ("%#St_cwd_sep#█" .. icon .. name)) or ""
      end,
    },
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

M.base46 = {
  integrations = {},
}

M.nvimtree = {
  git = {
    enable = true,
  },

  renderer = {
    highlight_git = true,
    icons = {
      show = {
        git = true,
      },
    },
  },
}

return M
