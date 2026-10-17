-- Run: nvim --headless -u NONE -l tests/note_mappings.lua
vim.opt.rtp:append(vim.fn.getcwd())
vim.opt.rtp:append(vim.fn.expand "~/.local/share/nvim/lazy/astrocore")
vim.g.mapleader = " "

local function test()
  local astrocore = require "astrocore"
  -- Keep which-key's lazy-load registration queued for inspection.
  astrocore.on_load = function() end
  local mappings = require("plugins.mappings")[1].opts.mappings
  astrocore.set_mappings(mappings)

  local groups = {}
  for _, spec in ipairs(astrocore.which_key_queue) do
    groups[spec.mode .. ":" .. spec[1]] = spec.group
  end
  assert(groups["n:<Leader>N"] == "Notes")
  assert(groups["n:<Leader>Nj"] == "Journal")
  assert(groups["n:<Leader>Nl"] == "Links")
  assert(groups["x:<Leader>N"] == "Notes")
  assert(groups["x:<Leader>Nl"] == "Links")

  local commands = {}
  vim.api.nvim_create_user_command(
    "Obsidian",
    function(args) commands[#commands + 1] = args end,
    { nargs = "*", range = true }
  )
  local expected = {
    Nn = "new",
    Nf = "quick_switch",
    Ns = "search",
    Nb = "backlinks",
    Nr = "rename",
    Nc = "toggle_checkbox",
    No = "open",
    Nw = "workspace",
    ["N?"] = "",
    Njt = "today",
    Njy = "yesterday",
    Njn = "tomorrow",
    Njf = "dailies",
    Nlf = "follow_link",
    Nll = "links",
    Nlt = "toc",
  }
  for keys, command in pairs(expected) do
    local map = vim.fn.maparg(" " .. keys, "n", false, true)
    assert(map.desc and map.desc ~= "", "Missing which-key description: " .. keys)
    vim.cmd.normal(" " .. keys)
    assert(commands[#commands].args == command, "Wrong command: " .. keys)
  end

  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first line", "second line", "third line" })
  for keys, command in pairs { Nli = "link", Nln = "link_new" } do
    local map = vim.fn.maparg(" " .. keys, "x", false, true)
    assert(map.desc and map.desc ~= "")
    local input = vim.api.nvim_replace_termcodes("ggVj<Space>" .. keys, true, false, true)
    vim.api.nvim_feedkeys(input, "xt", false)
    local called = commands[#commands]
    assert(called.args == command)
    assert(called.range == 2 and called.line1 == 1 and called.line2 == 2, "Visual range lost")
  end
end

local ok, err = xpcall(test, debug.traceback)
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd "cquit 1"
else
  print "Note mapping tests passed"
  vim.cmd "qa!"
end
