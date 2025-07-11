local function lazygit()
  local astro = require "astrocore"
  local worktree = astro.file_worktree()
  local flags = worktree and (" --work-tree=%s --git-dir=%s"):format(worktree.toplevel, worktree.gitdir) or ""
  astro.toggle_term_cmd { cmd = "lazygit " .. flags, direction = "tab" }
end

local function open_git_diff()
  if vim.g.statusline_clickable_git ~= false then
    if pcall(require, "diffview") then
      require("diffview").open {}
    else
      lazygit()
    end
  end
end

local function mode_letter()
  local mode_map = {
    n = "N", -- Normal
    no = "N", -- Operator-pending
    v = "V", -- Visual
    V = "L", -- Visual Line
    ["\22"] = "B", -- Visual Block (CTRL-V)
    s = "S", -- Select
    S = "L", -- Select Line
    ["\19"] = "B", -- Select Block (CTRL-S)
    i = "I", -- Insert
    ic = "I", -- Insert (completion)
    ix = "I", -- Insert (completion)
    R = "R", -- Replace
    Rc = "R", -- Replace (completion)
    Rv = "R", -- Virtual Replace
    c = "C", -- Command
    cv = "C", -- Vim Ex mode
    ce = "C", -- Normal Ex mode
    r = "r", -- Hit-enter prompt
    rm = "r", -- More prompt
    ["r?"] = "r", -- Confirm prompt
    ["!"] = "!", -- Shell or external command is executing
    t = "T", -- Terminal
  }

  local mode = vim.api.nvim_get_mode().mode
  return mode_map[mode] or "?"
end

local function get_root_dir()
  local ok, result
  local path = vim.api.nvim_buf_get_name(0)
  local cwd = vim.fn.getcwd()

  -- If buffer is empty, fall back to cwd name
  if path == "" then return vim.fn.fnamemodify(cwd, ":t") end

  -- Try LSP root
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    local root = client.config.root_dir
    if root and path:sub(1, #root) == root then return vim.fn.fnamemodify(root, ":t") end
  end

  -- Try Git root safely
  ok, result = pcall(function()
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.fnameescape(path) .. " rev-parse --show-toplevel")[1]
    if git_root and git_root ~= "" and vim.fn.isdirectory(git_root) == 1 then
      return vim.fn.fnamemodify(git_root, ":t")
    end
  end)
  if ok and result then return result end

  -- Fallback: name of current working directory
  return vim.fn.fnamemodify(cwd, ":t")
end

local function get_highlight_fg(group)
  local hl = vim.api.nvim_get_hl(0, { name = group })
  return hl.fg and string.format("#%06x", hl.fg) or nil
end

local get_spellang = function()
  if vim.opt.spell:get() ~= true then return "" end
  local lang = table.concat(vim.opt_local.spelllang:get(), "|")
  return lang == "" and "[--]" or "[" .. lang .. "]"
end

return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  specs = {
    {
      "rebelot/heirline.nvim",
      optional = true,
      opts = function(_, opts) opts.statusline = nil end,
    },
  },
  config = function()
    -- Custom Lualine component to show attached language server
    local clients_lsp = function()
      local clients = vim.lsp.get_clients()

      for _, client in pairs(clients) do
        if client.name == "copilot" then return " " end
      end
      return ""
    end

    local dfg = get_highlight_fg "Comment" or "#888888"

    require("lualine").setup {
      options = {
        theme = "auto",
        globalstatus = true,
        disabled_filetypes = { "alpha", "snacks_dashboard" },
      },
      sections = {
        lualine_a = {
          { get_root_dir },
        },
        lualine_b = {
          {
            "branch",
            icon = "",
            padding = { left = 2, right = 1 },
            on_click = function() open_git_diff() end,
          },
        },
        lualine_c = {
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            colored = false,
            on_click = function() open_git_diff() end,
            color = function() return { fg = dfg } end,
          },
        },
        lualine_x = {
          {
            "diagnostics",
            symbols = { error = " ", warn = " ", info = " ", hint = " " },
            update_in_insert = true,
          },
          { clients_lsp },
          { get_spellang },
        },
        lualine_y = {
          {
            "filetype",
            icon_only = true,
            padding = { left = 1, right = 0 },
            separator = "",
          },
          {
            "filename",
            padding = { left = 0, right = 1 },
            file_status = true, -- Displays file status (readonly status, modified status)
            path = 0, -- 0: Just the filename, 1: Relative path, 2: Absolute path
            symbols = { modified = " ", readonly = " ", unnamed = "[No Name]" },
          },
          { "%l:%c (%p%%)" },
        },
        lualine_z = {
          { mode_letter, padding = { left = 2, right = 2 } },
        },
      },
      inactive_sections = {
        lualine_a = { "filename" },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {},
        lualine_y = {},
        lualine_z = { "location" },
      },
      extensions = { "toggleterm", "trouble", "neo-tree" },
    }
  end,
}
