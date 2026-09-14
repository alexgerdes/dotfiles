-- Run with nvim --headless -u NONE -l tools/zk-context/verify.lua
local source = debug.getinfo(1, "S").source:sub(2)
local repo = vim.fs.normalize(vim.fs.dirname(source) .. "/../..")
package.path = repo .. "/.config/nvim/lua/?.lua;" .. package.path
local context = require "zk_context"
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/.zk", "p")
local fixture = {
  "---",
  "date: " .. os.date "%Y-%m-%d",
  "tags: []",
  "location: null",
  "weather: null",
  "temperature_c: null",
  "---",
  "",
  "# Fixture",
  "Original text",
}
local path = root .. "/test.md"
vim.fn.writefile(fixture, path)
vim.cmd.edit(vim.fn.fnameescape(path))
local buf = vim.api.nvim_get_current_buf()
vim.api.nvim_buf_set_lines(buf, 9, 10, false, { "User's unsaved text" })
vim.api.nvim_buf_set_lines(buf, 3, 4, false, { 'location: "User place"' })
context.apply(buf, { location = "API place", weather = "Rain", temperature_c = 12 })
local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
assert(content:find('location: "User place"', 1, true))
assert(content:find('weather: "Rain"', 1, true))
assert(content:find("User's unsaved text", 1, true))
assert(not content:find("context_pending", 1, true))
assert(vim.bo[buf].modified)
assert(vim.fn.readfile(path)[10] == "Original text", "Unsaved buffer was written")
vim.cmd "write"
context.apply(buf, { location = "Different", temperature_c = 30 })
assert(vim.fn.readfile(path)[6] == "temperature_c: 12", "Existing value replaced")

local old = vim.deepcopy(fixture)
old[2] = "date: 2012-08-21"
vim.api.nvim_buf_set_lines(buf, 0, -1, false, old)
context.apply(buf, { location = "Wrong historical place" })
assert(vim.api.nvim_buf_get_lines(buf, 3, 4, false)[1] == "location: null")

vim.api.nvim_buf_set_lines(buf, 0, -1, false, fixture)
vim.cmd "write"
local callback
local calls = 0
vim.system = function(_, _, cb)
  calls = calls + 1
  callback = cb
end
context.refresh(buf)
context.refresh(buf)
assert(calls == 1, "Concurrent lookups were not coalesced")
assert(vim.fn.readfile(path)[4] == "location: null", "Lookup blocked note creation")
callback({ code = 0, stdout = vim.json.encode { location = "Fixture city", latitude = 57.123456, longitude = 11.654321, weather = "Clear" } })
vim.wait(1000, function() return vim.fn.readfile(path)[4] ~= "location: null" end)
assert(vim.fn.readfile(path)[4] == 'location: "Fixture city (57.12346, 11.65432)"', "Coordinates or saving incorrect")
assert(not vim.bo[buf].modified)
print("PASS: nonblocking lookup, coalescing, save behavior, user edits, historical-note protection")
vim.cmd "qa!"
