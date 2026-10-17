-- Match this vault's Templater workflow without executing arbitrary template JS.
local M = {}
local root = vim.fs.normalize(vim.fn.expand "~/Repos/chalmers/obsidian")
local pending = {}
local adapter = vim.fn.stdpath "config" .. "/scripts/obsidian-note-context.cjs"

local function relative(path)
  path = vim.fs.normalize(path)
  if path:sub(1, #root + 1) == root .. "/" and path:sub(-3) == ".md" then return path:sub(#root + 2) end
end

local function inside(path, folder) return folder == "/" or path:sub(1, #folder + 1) == folder .. "/" end

local function template_for(path)
  local rel = relative(path)
  if not rel then return end
  local ok, settings = pcall(
    function()
      return vim.json.decode(
        table.concat(vim.fn.readfile(root .. "/.obsidian/plugins/templater-obsidian/data.json"), "\n")
      )
    end
  )
  if not ok then return nil, "Cannot read the Work vault's Templater settings" end
  for _, ignored in ipairs(settings.ignore_folders_on_creation or {}) do
    if inside(rel, ignored.folder) then return end
  end
  local selected, specificity
  for _, entry in ipairs(settings.folder_templates or {}) do
    local length = entry.folder == "/" and 0 or #entry.folder
    if inside(rel, entry.folder) and (not specificity or length > specificity) then
      selected, specificity = entry.template, length
    end
  end
  return selected and root .. "/" .. selected
end

local function date_heading(path)
  local title = vim.fn.fnamemodify(path, ":t:r")
  local year, month, day = title:match "^(%d%d%d%d)%-(%d%d)%-(%d%d)$"
  local timestamp = os.time()
  if year then
    local candidate = os.time { year = tonumber(year), month = tonumber(month), day = tonumber(day), hour = 12 }
    if candidate and os.date("%Y-%m-%d", candidate) == title then timestamp = candidate end
  end
  return os.date("%A, ", timestamp) .. tonumber(os.date("%d", timestamp)) .. os.date(" %B %Y", timestamp)
end

function M.render(path, template)
  local text = table.concat(vim.fn.readfile(template), "\n")
  -- The existing leading execution block computes the values supplied below.
  text = text:gsub("^<%%%*.-%%>\n", "", 1)
  local offset = os.date("%z"):gsub("(%d%d)(%d%d)$", "%1:%2")
  local values = {
    ["JSON.stringify(created)"] = vim.json.encode(os.date "%Y-%m-%dT%H:%M:%S" .. offset),
    ["JSON.stringify(context.location)"] = '""',
    ["JSON.stringify(context.weather)"] = '""',
    ['noteDate.format("dddd, D MMMM YYYY")'] = date_heading(path),
    ["tp.file.cursor()"] = "\1CURSOR\1",
  }
  text = text:gsub("<%%(.-)%%>", function(expression)
    expression = vim.trim(expression)
    assert(values[expression], "Unsupported Templater expression: " .. expression)
    return values[expression]
  end)
  local lines, cursor = vim.split(text, "\n", { plain = true }), nil
  for index, line in ipairs(lines) do
    local column = line:find("\1CURSOR\1", 1, true)
    if column then
      cursor = { index, column - 1 }
      lines[index] = line:gsub("\1CURSOR\1", "")
    end
  end
  return lines, cursor
end

local function notify(message) vim.notify(message, vim.log.levels.WARN, { title = "Work note templates" }) end

local function fill_context(buf, path, token)
  if vim.fn.executable "node" ~= 1 then
    notify "Node.js not found; location and weather left blank"
    return
  end
  vim.system(
    { "node", adapter, root .. "/_templates/scripts/note_context.js" },
    { text = true, timeout = 75000 },
    function(result)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) or vim.api.nvim_buf_get_name(buf) ~= path then return end
        if vim.b[buf].work_template_token ~= token then return end
        local ok, context = pcall(vim.json.decode, result.stdout or "")
        if result.code ~= 0 or not ok or type(context) ~= "table" then
          notify "Location/weather lookup failed; fields left blank"
          return
        end
        if context.error then notify(context.error) end
        -- Only replace untouched placeholders, never overwrite the user's edits.
        for index, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
          if index > 1 and line == "---" then break end
          for _, field in ipairs { "location", "weather" } do
            if line == field .. ': ""' and type(context[field]) == "string" then
              vim.api.nvim_buf_set_lines(
                buf,
                index - 1,
                index,
                false,
                { field .. ": " .. vim.json.encode(context[field]) }
              )
            end
          end
        end
      end)
    end
  )
end

function M.apply(buf, allow_generated)
  if not vim.api.nvim_buf_is_valid(buf) or vim.b[buf].work_template_token then return end
  local path = vim.api.nvim_buf_get_name(buf)
  local template, err = template_for(path)
  if err then notify(err) end
  if not template then return end
  local current = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  if not allow_generated and not (#current == 1 and current[1] == "") then return end
  local ok, lines, cursor = pcall(M.render, path, template)
  if not ok then
    notify(tostring(lines))
    return
  end
  local token = tostring(vim.uv.hrtime())
  vim.b[buf].work_template_token = token
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  if cursor then
    for _, win in ipairs(vim.fn.win_findbuf(buf)) do
      vim.api.nvim_win_set_cursor(win, cursor)
    end
  end
  fill_context(buf, path, token)
end

function M.on_create(note)
  if not note.path then return end
  local path = vim.fs.normalize(tostring(note.path))
  if relative(path) and not vim.uv.fs_stat(path) then pending[path] = true end
end

function M.setup(opts)
  root = vim.fs.normalize(opts and opts.root or vim.fn.expand "~/Repos/chalmers/obsidian")
  local group = vim.api.nvim_create_augroup("WorkObsidianTemplates", { clear = true })
  vim.api.nvim_create_autocmd("BufNewFile", {
    group = group,
    pattern = "*.md",
    callback = function(ev) M.apply(ev.buf, false) end,
  })
  -- Obsidian commands write a new file before opening its buffer.
  vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = group,
    pattern = "*.md",
    callback = function(ev)
      local path = vim.api.nvim_buf_get_name(ev.buf)
      if pending[path] then
        pending[path] = nil
        M.apply(ev.buf, true)
      end
    end,
  })
end

return M
