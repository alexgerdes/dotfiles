-- Run: nvim --headless -u NONE -l tests/obsidian_work_templates.lua
vim.opt.rtp:append(vim.fn.getcwd())
local module = require "obsidian_work_templates"
local scratch = vim.fn.tempname()
local source = vim.fn.expand "~/Repos/chalmers/obsidian"
local requests = {}
local original_system = vim.system
vim.system = function(command, opts, callback)
  if command[1] ~= "node" then return original_system(command, opts, callback) end
  requests[#requests + 1] = callback
  return { kill = function() end }
end

local function equal(expected, actual)
  assert(vim.deep_equal(expected, actual), "Expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual))
end

local function edit(path)
  vim.cmd("edit! " .. vim.fn.fnameescape(path))
  return vim.api.nvim_get_current_buf()
end

local function lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end

local function test()
  vim.fn.mkdir(scratch .. "/.obsidian/plugins/templater-obsidian", "p")
  vim.fn.mkdir(scratch .. "/_templates", "p")
  vim.fn.mkdir(scratch .. "/journal", "p")
  vim.fn.mkdir(scratch .. "/alg/nested", "p")
  vim.fn.writefile(
    vim.fn.readfile(source .. "/.obsidian/plugins/templater-obsidian/data.json"),
    scratch .. "/.obsidian/plugins/templater-obsidian/data.json"
  )
  for _, name in ipairs { "Daily", "Default", "ALG" } do
    vim.fn.writefile(
      vim.fn.readfile(source .. "/_templates/" .. name .. ".md"),
      scratch .. "/_templates/" .. name .. ".md"
    )
  end
  module.setup { root = scratch }
  edit(scratch .. "/journal/2026-10-17.md")
  equal("# Saturday, 17 October 2026", lines()[6])
  equal({ 8, 0 }, vim.api.nvim_win_get_cursor(0))
  assert(lines()[2]:match '^created: "%d%d%d%d%-%d%d%-%d%dT%d%d:%d%d:%d%d[%+%-]%d%d:%d%d"$')
  local initial = lines()
  module.apply(0, true)
  equal(initial, lines())
  vim.api.nvim_buf_set_lines(0, 2, 3, false, { 'location: "my edit"' })
  requests[#requests] { code = 0, stdout = vim.json.encode { location = "Gothenburg", weather = "Clear sky, 10°C" } }
  vim.wait(20)
  equal('location: "my edit"', lines()[3])
  equal('weather: "Clear sky, 10°C"', lines()[4])

  edit(scratch .. "/alg/nested/meeting.md")
  equal("  - alg", lines()[6])
  equal("# ALG", lines()[8])
  equal({ 12, 1 }, vim.api.nvim_win_get_cursor(0)) -- normal mode clamps after '- '
  edit(scratch .. "/other.md")
  equal(6, #lines())
  equal({ 6, 0 }, vim.api.nvim_win_get_cursor(0))

  edit(scratch .. "/_templates/untouched.md")
  equal({ "" }, lines())
  edit(scratch .. "/../outside.md")
  equal({ "" }, lines())
  vim.fn.writefile({ "existing note" }, scratch .. "/existing.md")
  edit(scratch .. "/existing.md")
  equal({ "existing note" }, lines())
  vim.fn.writefile({}, scratch .. "/empty.md")
  edit(scratch .. "/empty.md")
  equal({ "" }, lines())

  -- The real obsidian.nvim creation/write/open lifecycle, in the scratch vault.
  vim.opt.rtp:append(vim.fn.expand "~/.local/share/nvim/lazy/obsidian.nvim")
  vim.opt.rtp:append(vim.fn.expand "~/.local/share/nvim/lazy/plenary.nvim")
  require("obsidian").setup {
    legacy_commands = false,
    workspaces = { { name = "test", path = scratch } },
    frontmatter = { enabled = false },
    daily_notes = { folder = "journal", date_format = "YYYY/YYYY-MM-DD", default_tags = {} },
    ui = { enable = false },
    footer = { enabled = false },
    callbacks = { create_note = module.on_create },
  }
  assert(not Obsidian._config_error, Obsidian._config_error)
  local note = require("obsidian.note").create { id = "command-created", dir = scratch, verbatim = true }
  note:write()
  note:open { sync = true }
  equal(6, #lines())
  equal('location: ""', lines()[3])
  equal({ 6, 0 }, vim.api.nvim_win_get_cursor(0))
  vim.cmd.write()
  equal(lines(), vim.fn.readfile(tostring(note.path)))
  assert(not table.concat(lines(), "\n"):find "aliases:")

  local daily = require("obsidian.daily").daily { date = os.time { year = 2026, month = 10, day = 18, hour = 12 } }
  equal(scratch .. "/journal/2026/2026-10-18.md", tostring(daily.path))
  daily:write()
  daily:open { sync = true }
  equal("# Sunday, 18 October 2026", lines()[6])
  equal({ 8, 0 }, vim.api.nvim_win_get_cursor(0))
  requests[#requests] { code = 1, stdout = "" }
  vim.wait(20)
  equal('location: ""', lines()[3])
  equal('weather: ""', lines()[4])

  local next_year = require("obsidian.daily").daily { date = os.time { year = 2027, month = 1, day = 1, hour = 12 } }
  equal(scratch .. "/journal/2027/2027-01-01.md", tostring(next_year.path))
  next_year:write()
  next_year:open { sync = true }
  equal("# Friday, 1 January 2027", lines()[6])

  -- Validate the actual plugin specification, including workspace overrides.
  for _, spec in ipairs(require "plugins.user") do
    if spec[1] == "obsidian-nvim/obsidian.nvim" then
      local normalized = require("obsidian.config").normalize(spec.opts)
      equal(false, normalized.workspaces[2].overrides.frontmatter.enabled)
      equal("YYYY/YYYY-MM-DD", normalized.workspaces[2].overrides.daily_notes.date_format)
      equal(nil, normalized.workspaces[1].overrides)
    end
  end
end

local ok, err = xpcall(test, debug.traceback)
vim.system = original_system
vim.cmd "silent! %bwipeout!"
vim.fn.delete(scratch, "rf")
if not ok then
  io.stderr:write(err .. "\n")
  vim.cmd "cquit 1"
else
  print "Work template tests passed"
  vim.cmd "qa!"
end
