return {
  {
    "goolord/alpha-nvim",

    lazy = false,
    keys = {
      { "<leader>;", "<cmd>Alpha<cr>", desc = "Welcome screen" },
    },
    event = "VimEnter",

    opts = function()
      local dashboard = require "alpha.themes.dashboard"
      local logo = {
        [[  ██████   █████                   █████   █████  ███                  ]],
        [[ ░░██████ ░░███                   ░░███   ░░███  ░░░                   ]],
        [[  ░███░███ ░███   ██████   ██████  ░███    ░███  ████  █████████████   ]],
        [[  ░███░░███░███  ███░░███ ███░░███ ░███    ░███ ░░███ ░░███░░███░░███  ]],
        [[  ░███ ░░██████ ░███████ ░███ ░███ ░░███   ███   ░███  ░███ ░███ ░███  ]],
        [[  ░███  ░░█████ ░███░░░  ░███ ░███  ░░░█████░    ░███  ░███ ░███ ░███  ]],
        [[  █████  ░░█████░░██████ ░░██████     ░░███      █████ █████░███ █████ ]],
        [[ ░░░░░    ░░░░░  ░░░░░░   ░░░░░░       ░░░      ░░░░░ ░░░░░ ░░░ ░░░░░  ]],
        [[                                                                       ]],
      }

      -- Header
      dashboard.section.header.val = logo
      dashboard.section.header.opts.hl = "String"
      dashboard.opts.layout[1].val = 3

      -- Buttons
      dashboard.section.buttons.val = {
        dashboard.button("f", " " .. " Find file", "<cmd>Telescope find_files <CR>"),
        dashboard.button("n", " " .. " New file", "<cmd>ene <BAR> startinsert <CR>"),
        dashboard.button("r", " " .. " Recent files", "<cmd>Telescope oldfiles <CR>"),
        dashboard.button("g", " " .. " Find text", "<cmd>Telescope live_grep <CR>"),
        dashboard.button("s", " " .. " Restore Session", "<cmd>SessionManager load_session <CR>"),
        -- dashboard.button("m", " " .. " Mappings", "<cmd>NvCheatsheet<CR>"),
        -- dashboard.button("l", "󰒲 " .. " Lazy", "<cmd>Lazy<CR>"),
        -- dashboard.button("c", " " .. " Themes", "<cmd>Telescope themes<CR>"),
        -- dashboard.button("c", " " .. " Config", "<cmd>cd ~/.config/nvim | e $MYVIMRC <CR>"),
        dashboard.button("q", " " .. " Quit", "<cmd>qa<CR>"),
      }
      for i = 1, #dashboard.section.buttons.val do
        dashboard.section.buttons.val[i].opts.width = 30
      end

      -- Footer
      dashboard.section.footer.val = require "alpha.fortune"()

      return dashboard
    end,

    config = function(_, dashboard)
      -- close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)
    end,
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
}
