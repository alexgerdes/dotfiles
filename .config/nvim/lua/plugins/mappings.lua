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
        },
        i = {
          -- Fix Alt accent keys in MacOS
          ["<M-e>"] = { "<C-k>'" },
          ["<M-`>"] = { "<C-k>`" },
          ["<M-i>"] = { "<C-k>^" },
          ["<M-u>"] = { "<C-k>:" },
        },
      },
    },
  },
}
