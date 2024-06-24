require "nvchad.mappings"

local map = vim.keymap.set
local base46 = require "base46"
local gitsigns = require "gitsigns"

-- Use ; for command mode
map("n", ";", ":", { desc = "CMD enter command mode" })

-- Save with CTRL-s
map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Restore CTRL-i for jumping forward
map("n", "<C-i>", "<C-i>", { noremap = true })

-- LSP actions
map("n", "<leader>lh", vim.lsp.buf.hover, { desc = "Show information for under cursor" }) -- show documentation for what is under cursor
map("n", "<leader>lD", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<leader>lw", vim.lsp.buf.declaration, { desc = "Go to declaration" }) -- go to declaration
map("n", "<leader>ld", vim.diagnostic.open_float, { desc = "Show line diagnostics" }) -- show diagnostics for line
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" }) -- jump to previous diagnostic in buffer
map("n", "]d", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" }) -- jump to next diagnostic in buffer
map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "See available code actions" }) -- see available code actions, in visual mode will apply to selection
map("n", "<leader>lrn", vim.lsp.buf.rename, { desc = "Smart rename" }) -- smart rename
map("n", "<leader>lfD", "<cmd>Telescope diagnostics bufnr=0<CR>", { desc = "Show buffer diagnostics" }) -- show  diagnostics for file
map("n", "<leader>lfR", "<cmd>Telescope lsp_references<CR>", { desc = "Show LSP references" }) -- show definition, references
map("n", "<leader>lfd", "<cmd>Telescope lsp_definitions<CR>", { desc = "Show LSP definitions" }) -- show lsp definitions
map("n", "<leader>lfi", "<cmd>Telescope lsp_implementations<CR>", { desc = "Show LSP implementations" }) -- show lsp implementations
map("n", "<leader>lft", "<cmd>Telescope lsp_type_definitions<CR>", { desc = "Show LSP type definitions" }) -- show lsp type definitions
map("n", "<leader>lrs", ":LspRestart<CR>", { desc = "Restart LSP" }) -- mapping to restart lsp if necessary

-- Git actions
map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Stage hunk" })
map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Reset hunk" })
map("v", "<leader>gs", function()
  gitsigns.stage_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "Stage hunk" })
map("v", "<leader>gr", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "Reset hunk" })
map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Stage buffer" })
map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Undo stage hunk" })
map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Reset buffer" })
map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Preview hunk" })
map("n", "<leader>gb", function()
  gitsigns.blame_line { full = true }
end, { desc = "Blame line" })
map("n", "<leader>tb", gitsigns.toggle_current_line_blame, { desc = "Toggle current line blame" })
map("n", "<leader>gd", gitsigns.diffthis, { desc = "Diff this" })
map("n", "<leader>gD", function()
  gitsigns.diffthis "~"
end, { desc = "Diff this" })
map("n", "<leader>td", gitsigns.toggle_deleted, { desc = "" })

-- Toggle theme
map("n", "<leader>tt", base46.toggle_theme, { desc = "toggle theme" })

-- Session manager
map("n", "<leader>z", "<cmd> SessionManager <CR>", { desc = "Session manager" })

-- TeX stuff
map("n", "<leader>cv", "<cmd> VimtexView <CR>", { desc = "Tex: View" })
map("n", "<leader>cl", "<cmd> VimtexCompile <CR>", { desc = "Tex: Compile" })

-- AI
-- map({ "n", "v" }, "<leader>ww", ":Gen<CR>", { desc = "LLM Prompt" })
