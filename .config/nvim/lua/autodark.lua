-- Based on: https://oterodiaz.com/posts/making-neovim-and-emacs-adapt-to-system-dark-mode/
--
-- The function os_appearance_changed should be called on a mode change. You
-- can do this via a python script using pynvim. The iterm2_theme_monitor.py
-- in the scripts directory shows how.
--
-- An alternative is to poll from NeoVim and use the following function to ret
-- an osascript to get hold of the current mode.
--
-- local function getMode()
--   local cmd = "osascript -e 'tell application \"System Events\" to tell appearance preferences to return dark mode'"
--   local handle = io.popen(cmd)
--   local result = handle:read "*a"
--   handle:close()
--
--   return string.find(result, "true") ~= nil and Mode.Dark or Mode.Light
-- end

local M = {}

local Mode = { Dark = "Dark", Light = "Light" }

local function createSocket()
  local pid = vim.fn.getpid()
  local socket_name = "/tmp/nvim/nvim" .. pid .. ".sock"
  vim.fn.mkdir("/tmp/nvim", "p")
  vim.fn.serverstart(socket_name)
end

function os_appearance_changed(mode)
  local cfg = require "nvconfig"
  local target = mode == Mode.Dark and cfg.ui.dark_theme or cfg.ui.light_theme
  vim.notify("OS appearance changed, current mode: " .. mode)

  if cfg.ui.theme ~= target then
    require("base46").toggle_theme()
  end
end

M.setup = function()
  vim.api.nvim_create_augroup("custom_startup", {})

  vim.api.nvim_create_autocmd("VimEnter", {
    desc = "Create a socket for every nvim process",
    group = "custom_startup",
    once = true,
    callback = createSocket,
  })
end

return M
