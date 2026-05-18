local function select_opencode_server()
  require("opencode.server.discovery")
    .get_all()
    :next(function(servers)
      return require("opencode.ui.select_server").select_server(servers)
    end)
    :next(function(server)
      server:connect()
    end)
    :catch(function(err)
      if err then
        vim.notify(err, vim.log.levels.ERROR, { title = "opencode" })
      end
    end)
end

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
          ["<Leader>Os"] = { select_opencode_server, desc = "Select server" },
          ["<Leader>Op"] = { function() require("opencode").select() end, desc = "Select prompt" },
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
        v = {
          ["<Leader>Os"] = { select_opencode_server, desc = "Select server" },
          ["<Leader>Op"] = { function() require("opencode").select() end, desc = "Select prompt" },
        },
      },
    },
  },
}
