local notebooks = {
  work = vim.env.ZK_WORK_DIR or vim.fn.expand "~/OneDrive - Chalmers/Journal",
  personal = vim.env.ZK_PERSONAL_DIR or vim.fn.expand "~/Library/Mobile Documents/com~apple~CloudDocs/Journal",
}

-- zk compares paths against the real notebook root (OneDrive's home path is a symlink).
for name, path in pairs(notebooks) do
  notebooks[name] = vim.uv.fs_realpath(path) or path
end

local function current_notebook()
  local util = require "zk.util"
  local path = util.notebook_root(vim.api.nvim_buf_get_name(0))
    or util.notebook_root(vim.fn.getcwd())
    or vim.env.ZK_NOTEBOOK_DIR
    or notebooks.personal
  return vim.uv.fs_realpath(path) or path
end

local function daily(notebook)
  notebook = notebook or current_notebook()
  local path = notebook .. "/daily/" .. os.date "%Y-%m-%d" .. ".md"
  if vim.fn.filereadable(path) == 1 then
    vim.cmd.edit(vim.fn.fnameescape(path))
  else
    require("zk").new { notebook_path = notebook, dir = notebook .. "/daily" }
  end
end

local function notes(notebook)
  require("zk").edit({ notebook_path = notebook or current_notebook(), sort = { "modified" } }, { title = "Notes" })
end

local function new_note()
  local notebook = current_notebook()
  vim.ui.input({ prompt = "Note title: " }, function(title)
    if title and vim.trim(title) ~= "" then
      require("zk").new { notebook_path = notebook, dir = notebook .. "/notes", title = title }
    end
  end)
end

local function search()
  local notebook = current_notebook()
  vim.ui.input({ prompt = "Search note contents: " }, function(query)
    if query and vim.trim(query) ~= "" then
      require("zk").edit({ notebook_path = notebook, match = { query } }, { title = "Search notes" })
    end
  end)
end

---@type LazySpec
return {
  {
    "zk-org/zk-nvim",
    opts = {
      picker = "snacks_picker",
      lsp = {
        config = {
          cmd = { "/opt/homebrew/bin/zk", "lsp" },
          filetypes = { "markdown" },
          on_attach = function(client, bufnr) require("astrolsp").on_attach(client, bufnr) end,
        },
        auto_attach = { enabled = true },
      },
    },
    init = function() vim.env.ZK_NOTEBOOK_DIR = vim.env.ZK_NOTEBOOK_DIR or notebooks.personal end,
    cmd = { "ZkWork", "ZkPersonal", "ZkDaily" },
    config = function(_, opts)
      require("zk").setup(opts)
      require("zk_context").setup()
      local commands = require "zk.commands"
      commands.add("ZkWork", function() daily(notebooks.work) end)
      commands.add("ZkPersonal", function() daily(notebooks.personal) end)
      commands.add("ZkDaily", function() daily() end)
    end,
    keys = {
      { "<Leader>zw", function() daily(notebooks.work) end, desc = "Work: today's note" },
      { "<Leader>zp", function() daily(notebooks.personal) end, desc = "Personal: today's note" },
      { "<Leader>zW", function() notes(notebooks.work) end, desc = "Work: browse notes" },
      { "<Leader>zP", function() notes(notebooks.personal) end, desc = "Personal: browse notes" },
      { "<Leader>zd", function() daily() end, desc = "Today's note (current notebook)" },
      { "<Leader>zn", new_note, desc = "New note (current notebook)" },
      { "<Leader>zf", function() notes() end, desc = "Find notes" },
      { "<Leader>zs", search, desc = "Search note contents" },
      { "<Leader>zt", "<Cmd>ZkTags<CR>", desc = "Find notes by tag" },
      { "<Leader>zb", "<Cmd>ZkBacklinks<CR>", desc = "Backlinks" },
      { "<Leader>zl", "<Cmd>ZkLinks<CR>", desc = "Outgoing links" },
      { "<Leader>zi", "<Cmd>ZkInsertLink<CR>", desc = "Insert note link" },
      { "<Leader>zi", ":ZkInsertLinkAtSelection<CR>", mode = "x", desc = "Link selected text" },
    },
  },
  {
    "AstroNvim/astrocore",
    opts = { mappings = { n = { ["<Leader>z"] = { desc = "Zettelkasten" } } } },
  },
}
