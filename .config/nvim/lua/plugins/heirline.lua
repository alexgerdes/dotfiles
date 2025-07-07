return {
  {
    "AstroNvim/astroui",
    ---@type AstroUIOpts
    opts = {
      -- add new user interface icon
      icons = {
        VimIcon = "",
        GitBranch = "",
        GitAdd = "",
        GitChange = "",
        GitDelete = "",
      },
      -- modify variables used by heirline but not defined in the setup call directly
      status = {
        separators = {
          left = { "", " " }, -- separator for the left side of the statusline
          right = { " ", "" }, -- separator for the right side of the statusline
        },
        -- add new colors that can be used by heirline
        colors = function(hl)
          local get_hlgroup = require("astroui").get_hlgroup
          -- use helper function to get highlight group properties
          -- local comment_fg = get_hlgroup("Comment").fg
          local comment_fg = get_hlgroup("Comment").fg
          hl.git_added = comment_fg
          hl.git_changed = comment_fg
          hl.git_removed = comment_fg
          return hl
        end,
        attributes = {
          mode = { bold = true },
        },
      },
    },
  },
  {
    "rebelot/heirline.nvim",
    opts = function(_, opts)
      local status = require "astroui.status"

      local nav = {
        provider = "%l:%c (%p%%)",
      }

      opts.statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode {
          mode_text = { padding = { left = 1, right = 1 } },
        },
        status.component.git_branch(),
        status.component.git_diff(),
        status.component.cmd_info(),
        status.component.fill(),
        status.component.virtual_env(),
        status.component.diagnostics(),
        nav,
        status.component.file_info(),
      }
    end,
  },
}
