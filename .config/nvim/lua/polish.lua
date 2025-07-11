-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local opt = vim.opt

-- Basic settings
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true
opt.shell = "/bin/zsh"
opt.cursorline = true
opt.encoding = "utf-8"
opt.incsearch = true -- Starts search before enter
opt.autoread = true -- Reads files again if they have been changed outside of vim

-- Recognize docker files
vim.filetype.add { extension = { docker = "dockerfile" } }

-- Configure the flexoki colorscheme
if not vim.g.vscode then
  require("flexoki").setup {
    variant = "dawn", -- auto, moon, or dawn
    dim_inactive_windows = true,
    extend_background_behind_borders = true,

    enable = {
      terminal = true,
    },

    styles = {
      bold = true,
      italic = false,
    },

    groups = {
      border = "muted",
      link = "purple_two",
      panel = "surface",

      error = "red_one",
      hint = "purple_one",
      info = "cyan_one",
      ok = "green_one",
      warn = "orange_one",
      note = "blue_one",
      todo = "magenta_one",

      git_add = "green_one",
      git_change = "yellow_one",
      git_delete = "red_one",
      git_dirty = "yellow_one",
      git_ignore = "muted",
      git_merge = "purple_one",
      git_rename = "blue_one",
      git_stage = "purple_one",
      git_text = "magenta_one",
      git_untracked = "subtle",

      h1 = "purple_two",
      h2 = "cyan_two",
      h3 = "magenta_two",
      h4 = "orange_two",
      h5 = "blue_two",
      h6 = "cyan_two",
    },

    palette = {
      -- Override the builtin palette per variant
      -- dawn = {
      --   _nc = "#efefef",
      --   base = "#f9f9f9",
      --   surface = "#fafafa",
      --   overlay = "#efefef",
      -- },
    },

    highlight_groups = {
      -- Comment = { fg = "subtle" },
      -- VertSplit = { fg = "muted", bg = "muted" },
    },
  }
end
