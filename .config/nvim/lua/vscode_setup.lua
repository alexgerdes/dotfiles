-- Minimal config for the VS Code Neovim extension (vim.g.vscode).
-- Loaded from init.lua instead of lazy.nvim/AstroNvim: no plugins, LSP, treesitter or UI,
-- so Neovim starts and exits quickly when VS Code closes a window.

local vscode = require "vscode"
local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = ","

vim.notify = vscode.notify

-- Options (subset of polish.lua and AstroNvim defaults that matter for text editing)
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.shiftround = false
opt.expandtab = true
opt.autoindent = true
opt.smartindent = true
opt.copyindent = true
opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.clipboard = "unnamedplus"
opt.shadafile = "NONE" -- VS Code keeps its own history; skip ShaDa reads/writes on start and exit

-- Optional pure-Vimscript plugin, used only if the main config has installed it
local simple_align = vim.fn.stdpath "data" .. "/lazy/vim-simple-align"
if (vim.uv or vim.loop).fs_stat(simple_align) then opt.rtp:append(simple_align) end

local function trim_trailing_whitespace()
  local view = vim.fn.winsaveview()
  vim.cmd [[keeppatterns %s/\s\+$//e]]
  vim.fn.winrestview(view)
end

vim.api.nvim_create_user_command("TrimTrailingWhitespace", trim_trailing_whitespace, {
  desc = "Trim trailing whitespace",
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("vscode_highlight_yank", { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Keymaps: VS Code equivalents of the AstroNvim mappings (based on astrocommunity.recipes.vscode)
local function action(name, opts)
  return function() vscode.action(name, opts) end
end

local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true }) end

-- Basic actions
map("n", "<Leader>q", action "workbench.action.closeWindow", "Close window")
map("n", "<Leader>w", action "workbench.action.files.save", "Save")
map("n", "<Leader>n", action "welcome.showNewFileEntries", "New file")
map("n", "<Leader>xw", trim_trailing_whitespace, "Trim trailing whitespace")
map({ "n", "x" }, "<Leader>/", action "editor.action.commentLine", "Toggle comment")

-- Splits
map("n", "|", action "workbench.action.splitEditor", "Vertical split")
map("n", "\\", action "workbench.action.splitEditorDown", "Horizontal split")
map("n", "<C-H>", action "workbench.action.navigateLeft", "Move to left split")
map("n", "<C-J>", action "workbench.action.navigateDown", "Move to below split")
map("n", "<C-K>", action "workbench.action.navigateUp", "Move to above split")
map("n", "<C-L>", action "workbench.action.navigateRight", "Move to right split")

-- Terminal
map("n", "<F7>", action "workbench.action.terminal.toggleTerminal", "Toggle terminal")
map("n", "<C-'>", action "workbench.action.terminal.toggleTerminal", "Toggle terminal")

-- Buffers / editors
map("n", "]b", "<Cmd>Tabnext<CR>", "Next editor")
map("n", "[b", "<Cmd>Tabprevious<CR>", "Previous editor")
map("n", "<M-]>", "<Cmd>Tabnext<CR>", "Next editor")
map("n", "<M-[>", "<Cmd>Tabprevious<CR>", "Previous editor")
map("n", "<Leader>c", "<Cmd>Tabclose<CR>", "Close editor")
map("n", "<Leader>C", "<Cmd>Tabclose!<CR>", "Force close editor")
map("n", "<Leader>bc", action "workbench.action.closeOtherEditors", "Close other editors")
map("n", "<Leader>bp", "<Cmd>Tablast<CR>", "Last editor")

-- File explorer
map("n", "<Leader>e", action "workbench.files.action.focusFilesExplorer", "Explorer")
map("n", "<Leader>o", action "workbench.files.action.focusFilesExplorer", "Explorer")

-- Indentation
map("v", "<Tab>", action "editor.action.indentLines", "Indent")
map("v", "<S-Tab>", action "editor.action.outdentLines", "Outdent")

-- Diagnostics
map("n", "]d", action "editor.action.marker.nextInFiles", "Next diagnostic")
map("n", "[d", action "editor.action.marker.prevInFiles", "Previous diagnostic")

-- Pickers
map("n", "<Leader><Space>", action "workbench.action.quickOpen", "Find files")
map("n", "<Leader>ff", action "workbench.action.quickOpen", "Find files")
map(
  "n",
  "<Leader>fc",
  function() vscode.action("workbench.action.findInFiles", { args = { query = vim.fn.expand "<cword>" } }) end,
  "Find word under cursor"
)
map("n", "<Leader>fC", action "workbench.action.showCommands", "Commands")
map("n", "<Leader>fn", action "notifications.showList", "Notifications")
map("n", "<Leader>fo", action "workbench.action.openRecent", "Recent files")
map("n", "<Leader>ft", action "workbench.action.selectTheme", "Themes")
-- Runs the "code-rg" user task (VS Code tasks.json), a ripgrep + fzf picker from ~/.zshrc.local
map("n", "<Leader>fw", action("workbench.action.tasks.runTask", { args = { "code-rg" } }), "Find in files (rg + fzf)")
map("n", "<Leader>fb", action "workbench.action.showEditorsInGroup", "Open editors")

-- Git
map("n", "<Leader>gg", action "lazygit.openLazygit", "Lazygit")
map("n", "<Leader>gs", action "workbench.view.scm", "Source control")

-- LSP
map("n", "K", action "editor.action.showHover", "Hover")
map("n", "gI", action "editor.action.goToImplementation", "Go to implementation")
map("n", "gd", action "editor.action.revealDefinition", "Go to definition")
map("n", "gD", action "editor.action.revealDeclaration", "Go to declaration")
map("n", "gr", action "editor.action.goToReferences", "References")
map("n", "gy", action "editor.action.goToTypeDefinition", "Go to type definition")
map("n", "<Leader>la", action "editor.action.quickFix", "Code action")
map("n", "<Leader>lG", action "workbench.action.showAllSymbols", "Workspace symbols")
map("n", "<Leader>lR", action "editor.action.goToReferences", "References")
map("n", "<Leader>lr", action "editor.action.rename", "Rename")
map("n", "<Leader>ls", action "workbench.action.gotoSymbol", "Document symbols")
map("n", "<Leader>lf", action "editor.action.formatDocument", "Format document")
