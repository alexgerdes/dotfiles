local M = {}
local waiting = {}
local running = false
local attempted = {}
local helper = vim.fn.expand "~/Applications/ZK Context.app/Contents/MacOS/zk-context"
local fields = { "location", "weather", "temperature_c" }

local function eligible(bufnr, manual)
  if not vim.api.nvim_buf_is_valid(bufnr) or not vim.api.nvim_buf_is_loaded(bufnr) then return false end
  local path = vim.api.nvim_buf_get_name(bufnr)
  if not vim.fs.root(path, ".zk") then return false end
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 40, false)
  if lines[1] ~= "---" then return false end
  if not manual and attempted[path] then return false end
  local today, empty, present = false, false, {}
  for i = 2, #lines do
    local line = lines[i]
    if line == "---" then break end
    if line:match "^date:" then today = line:find(os.date "%Y-%m-%d", 1, true) ~= nil end
    for _, key in ipairs(fields) do
      if line:match("^" .. key .. ":") then present[key] = true end
      if line == key .. ": null" then empty = true end
    end
  end
  return today and empty and present.location and present.weather and present.temperature_c
end

-- Update only our empty frontmatter fields; all note text and user edits survive.
function M.apply(bufnr, data)
  if not eligible(bufnr, true) or not vim.bo[bufnr].modifiable then return end
  data = vim.deepcopy(data)
  if type(data.latitude) == "number" and type(data.longitude) == "number" then
    local place = type(data.location) == "string" and data.location or ""
    data.location = (place ~= "" and place .. " " or "") .. string.format("(%.5f, %.5f)", data.latitude, data.longitude)
  end
  local was_modified = vim.bo[bufnr].modified
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 40, false)
  for i = 2, #lines do
    if lines[i] == "---" then break end
    local replacement
    for _, key in ipairs(fields) do
      if lines[i] == key .. ": null" and data[key] ~= nil and data[key] ~= vim.NIL then
        replacement = key .. ": " .. vim.json.encode(data[key])
      end
    end
    if replacement then vim.api.nvim_buf_set_lines(bufnr, i - 1, i, false, { replacement }) end
  end
  if not was_modified and vim.bo[bufnr].modified and not vim.bo[bufnr].readonly then
    vim.api.nvim_buf_call(bufnr, function() vim.cmd "silent update" end)
  end
end

function M.refresh(bufnr, manual)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not eligible(bufnr, manual) then return end
  waiting[bufnr] = vim.api.nvim_buf_get_name(bufnr)
  attempted[waiting[bufnr]] = true
  if running then return end
  if vim.fn.executable(helper) ~= 1 then
    waiting = {}
    vim.notify("ZK Context helper is missing: " .. helper, vim.log.levels.WARN)
    return
  end
  running = true
  vim.system(manual and { helper, "--refresh" } or { helper }, { text = true, timeout = 25000 }, function(result)
    vim.schedule(function()
      running = false
      local ok, data = pcall(vim.json.decode, result.stdout or "")
      if not ok or type(data) ~= "table" then data = {} end
      local pending = waiting
      waiting = {}
      for buf, path in pairs(pending) do
        if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_buf_get_name(buf) == path then M.apply(buf, data) end
      end
      if result.code ~= 0 then
        vim.notify(
          data.error or "Location lookup unavailable; metadata left blank",
          vim.log.levels.WARN,
          { title = "zk" }
        )
      end
    end)
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("ZkContext", { clear = true })
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = group,
    pattern = "*.md",
    callback = function(event) M.refresh(event.buf) end,
  })
  vim.api.nvim_create_user_command("ZkContextRefresh", function() M.refresh(nil, true) end, {
    desc = "Retry empty location/weather fields in today's new zk note",
    force = true,
  })
  vim.schedule(function() M.refresh() end)
end

return M
