-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function initial_colorscheme()
  if (vim.uv or vim.loop).os_uname().sysname ~= "Darwin" then return "flexoki" end

  local result = vim.system({ "defaults", "read", "-g", "AppleInterfaceStyle" }, { text = true }):wait()
  local dark_mode = result.code == 0 and vim.trim(result.stdout or "") == "Dark"
  vim.o.background = dark_mode and "dark" or "light"
  return dark_mode and "catppuccin-mocha" or "flexoki"
end

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = initial_colorscheme(),
  },
}
