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
opt.relativenumber = false -- Relative line numbers

-- Disable autoformatting
vim.g.autoformat = false

-- Trim trailing whitespace
local function trim_trailing_whitespace()
  local view = vim.fn.winsaveview()
  vim.cmd [[keeppatterns %s/\s\+$//e]]
  vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command("TrimTrailingWhitespace", trim_trailing_whitespace, {
  desc = "Trim trailing whitespace",
})

-- Recognize docker files
vim.filetype.add { extension = { docker = "dockerfile" } }
