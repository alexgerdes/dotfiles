-- Credits to original theme https://github.com/kepano/flexoki/
-- This is a modified version of it

-- return colors
local M = {}


M.base_30 = {
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


M.base_16 = {
  base00 = M.base_30.black,
  base01 = M.base_30.black2,
  base02 = M.base_30.one_bg2,
  base03 = M.base_30.one_bg3,
  base04 = M.base_30.grey,
  base05 = "#383d42",
  base06 = "#2e3338",
  base07 = "#24292e",
  base08 = M.base_30.red,
  base09 = M.base_30.orange,
  base0A = M.base_30.dark_purple,
  base0B = M.base_30.green,
  base0C = M.base_30.cyan,
  base0D = M.base_30.blue,
  base0E = M.base_30.yellow,
  base0F = M.base_30.teal,
}
M.polish_hl = {
  syntax = {
    Keyword = { fg = M.base_30.cyan },
    Include = { fg = M.base_30.yellow },
    Tag = { fg = M.base_30.blue },
  },
  treesitter = {
    ["@keyword"] = { fg = M.base_30.cyan },
    ["@variable.parameter"] = { fg = M.base_30.pink },
    ["@tag.attribute"] = { fg = M.base_30.orange },
    ["@tag"] = { fg = M.base_30.blue },
    ["@string"] = { fg = M.base_30.green },
    ["@string.special.url"] = { fg = M.base_30.green },
    ["@markup.link.url"] = { fg = M.base_30.green },
    ["@punctuation.bracket"] = { fg = M.base_30.yellow },
  },

  telescope = {
    TelescopeMatching = { fg = M.base_30.dark_purple, bg = M.base_30.one_bg },
  },
}

M.type = "light"

M = require("base46").override_theme(M, "sehsa")

return M
