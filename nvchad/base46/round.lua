local config = require "nvconfig"
local get_theme_tb = require("base46").get_theme_tb
local colors = get_theme_tb "base_30"
local generate_color = require("base46.colors").change_hex_lightness

local statusline_bg = config.base46.transparency and "NONE" or colors.statusline_bg
local light_grey = generate_color(colors.light_grey, 8)

local M = {
  StatusLine = { bg = statusline_bg },
  St_gitIcons = { fg = colors.light_grey, bg = statusline_bg, bold = true },
  St_Lsp = { fg = colors.light_grey, bg = statusline_bg },
  St_LspMsg = { fg = colors.green, bg = statusline_bg },
  St_EmptySpace = { fg = colors.grey, bg = colors.lightbg },
  St_file = { bg = colors.lightbg, fg = colors.white },
  St_file_sep = { bg = statusline_bg, fg = colors.lightbg },
  St_cwd_icon = { fg = colors.white, bg = colors.lightbg },
  St_cwd_text = { fg = colors.white, bg = colors.lightbg },
  St_cwd_sep = { fg = colors.lightbg, bg = statusline_bg },
  St_pos_sep = { fg = colors.grey, bg = colors.lightbg },
  St_pos_icon = { fg = colors.white, bg = colors.grey },
  St_pos_text = { fg = colors.white, bg = colors.grey },
  St_pos_sep_out = { fg = colors.grey, bg = statusline_bg },
  St_trim = { fg = colors.light_grey, bg = colors.black },

  -- lsp highlights
  St_lspError = { fg = colors.red, bg = statusline_bg },
  St_lspWarning = { fg = colors.yellow, bg = statusline_bg },
  St_LspHints = { fg = colors.purple, bg = statusline_bg },
  St_LspInfo = { fg = colors.green, bg = statusline_bg },
}

local function genModes_hl(modename, col)
  M["St_" .. modename .. "Mode"] = { fg = colors.black, bg = colors[col], bold = true }
  M["St_" .. modename .. "ModeSep"] = { fg = colors[col], bg = colors.lightbg }
  M["St_" .. modename .. "ModeSepOut"] = { fg = colors[col], bg = statusline_bg }
end

genModes_hl("Normal", "nord_blue")
genModes_hl("Visual", "cyan")
genModes_hl("Insert", "dark_purple")
genModes_hl("Terminal", "green")
genModes_hl("NTerminal", "yellow")
genModes_hl("Replace", "orange")
genModes_hl("Confirm", "teal")
genModes_hl("Command", "green")
genModes_hl("Select", "blue")

return M
