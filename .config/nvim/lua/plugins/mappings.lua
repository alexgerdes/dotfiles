return {
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      mappings = {
        -- first key is the mode
        n = {
          -- Switch between buffers.
          ["<M-]>"] = { ":bn<CR>" },
          ["<M-[>"] = { ":bp<CR>" },
          -- Smart files picker
          ["<leader><space>"] = { ":lua Snacks.picker.smart()<CR>", desc = "Smart find files" },
          ["<leader>xw"] = { "<cmd>TrimTrailingWhitespace<CR>", desc = "Trim trailing whitespace" },

          -- Notes: named groups are registered with which-key by AstroCore.
          ["<Leader>N"] = { desc = "Notes" },
          ["<Leader>Nn"] = { "<cmd>Obsidian new<CR>", desc = "New note" },
          ["<Leader>Nf"] = { "<cmd>Obsidian quick_switch<CR>", desc = "Find note" },
          ["<Leader>Ns"] = { "<cmd>Obsidian search<CR>", desc = "Search note contents" },
          ["<Leader>Nb"] = { "<cmd>Obsidian backlinks<CR>", desc = "Backlinks" },
          ["<Leader>Nr"] = { "<cmd>Obsidian rename<CR>", desc = "Rename note and update links" },
          ["<Leader>Nc"] = { "<cmd>Obsidian toggle_checkbox<CR>", desc = "Toggle checkbox" },
          ["<Leader>No"] = { "<cmd>Obsidian open<CR>", desc = "Open in Obsidian app" },
          ["<Leader>Nw"] = { "<cmd>Obsidian workspace<CR>", desc = "Switch workspace" },
          ["<Leader>N?"] = { "<cmd>Obsidian<CR>", desc = "All Obsidian commands" },

          ["<Leader>Nj"] = { desc = "Journal" },
          ["<Leader>Njt"] = { "<cmd>Obsidian today<CR>", desc = "Today" },
          ["<Leader>Njy"] = { "<cmd>Obsidian yesterday<CR>", desc = "Yesterday / previous workday" },
          ["<Leader>Njn"] = { "<cmd>Obsidian tomorrow<CR>", desc = "Tomorrow / next workday" },
          ["<Leader>Njf"] = { "<cmd>Obsidian dailies<CR>", desc = "Find daily note" },

          ["<Leader>Nl"] = { desc = "Links" },
          ["<Leader>Nlf"] = { "<cmd>Obsidian follow_link<CR>", desc = "Follow link" },
          ["<Leader>Nll"] = { "<cmd>Obsidian links<CR>", desc = "List links in note" },
          ["<Leader>Nlt"] = { "<cmd>Obsidian toc<CR>", desc = "Table of contents" },
        },
        x = {
          ["<Leader>N"] = { desc = "Notes" },
          ["<Leader>Nl"] = { desc = "Links" },
          -- ':' preserves the visual selection as the command's range.
          ["<Leader>Nli"] = { ":Obsidian link<CR>", desc = "Link selected text to note" },
          ["<Leader>Nln"] = { ":Obsidian link_new<CR>", desc = "Create linked note from selection" },
        },
        i = {
          -- Fix Alt accent keys in MacOS
          ["<M-e>"] = { "<C-k>'" },
          ["<M-`>"] = { "<C-k>`" },
          ["<M-i>"] = { "<C-k>^" },
          ["<M-u>"] = { "<C-k>:" },
          -- Save using Ctrl-S
          ["<C-s>"] = { "<C-o>:w<CR>", desc = "Save file" },
        },
      },
    },
  },
}
