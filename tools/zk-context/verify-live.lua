-- Exercises the actual Swift helper against a disposable notebook.
local source = debug.getinfo(1, "S").source:sub(2)
local repo = vim.fs.normalize(vim.fs.dirname(source) .. "/../..")
package.path = repo .. "/.config/nvim/lua/?.lua;" .. package.path
local root = vim.fn.tempname()
vim.fn.mkdir(root .. "/.zk", "p")
local path = root .. "/context.md"
vim.fn.writefile({
  "---", "date: " .. os.date "%Y-%m-%d", "tags: []",
  "location: null", "weather: null", "temperature_c: null",
  "---", "", "# Disposable context check",
}, path)
require("zk_context").setup()
local started = vim.uv.hrtime()
vim.cmd.edit(vim.fn.fnameescape(path))
local open_ms = (vim.uv.hrtime() - started) / 1000000
assert(vim.wait(26000, function() return vim.fn.readfile(path)[4] ~= "location: null" end), "Lookup timed out")
local lines = vim.fn.readfile(path)
assert(lines[4] ~= "location: null", "Place lookup failed")
assert(lines[5] ~= "weather: null", "Weather lookup failed")
print(string.format("PASS: note opened in %.1f ms; metadata saved after %.1f ms", open_ms, (vim.uv.hrtime() - started) / 1000000))
vim.cmd "qa!"
