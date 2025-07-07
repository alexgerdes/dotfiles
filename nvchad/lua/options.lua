require "nvchad.options"

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
-- opt.colorcolumn = "80"
opt.guicursor = "i:ver50-iCursor-blinkwait300-blinkon200-blinkoff150"
opt.shell = "/bin/zsh"
opt.cursorline = true
opt.encoding = "utf-8"
opt.hlsearch = true  -- Highlight search matches
opt.incsearch = true -- Starts search before enter
opt.autoread = true  -- Reads files again if they have been changed outside of vim
opt.linebreak = true
opt.wrap = true

-- Override cursor color in insert mode
vim.cmd [[highlight iCursor guifg=orange guibg=orange]]

-- Set color for column line
vim.cmd [[highlight ColorColumn ctermbg=7 guibg=LineNr]]

vim.filetype.add { extension = { docker = "dockerfile" } }

-- Toggle auto completion
local function toggle_autocomplete()
  local cmp = require "cmp"
  local current_setting = cmp.get_config().completion.autocomplete
  if current_setting and #current_setting > 0 then
    cmp.setup { completion = { autocomplete = false } }
    vim.notify "Autocomplete disabled"
  else
    cmp.setup { completion = { autocomplete = { cmp.TriggerEvent.TextChanged } } }
    vim.notify "Autocomplete enabled"
  end
end
vim.api.nvim_create_user_command("NvimCmpToggle", toggle_autocomplete, {})

-- Start plugins
require("gitsigns").setup()
require("telescope").load_extension "ui-select"
require("codecompanion").setup {
  adapters = {
    openai = function()
      return require("codecompanion.adapters").extend("openai", {
        env = {
          -- api_key = cmd:op read op://personal/openai/api key --no-newline",
        },
      })
    end,
  },
}
