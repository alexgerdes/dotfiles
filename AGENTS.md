# AGENTS.md
This guide is for coding agents working in this dotfiles repository.

The current actionable project is the Neovim config in `.config/nvim`.
Most conventions below are inferred from that codebase, not from unrelated dotfiles.

## Scope and layout
- Repo root: `/Users/alex/Repos/dotfiles`
- Main project root: `/Users/alex/Repos/dotfiles/.config/nvim`
- Entrypoint: `.config/nvim/init.lua`
- Lazy bootstrap: `.config/nvim/lua/lazy_setup.lua`
- Late runtime tweaks: `.config/nvim/lua/polish.lua`
- Plugin specs: `.config/nvim/lua/plugins/*.lua`
- Theme helpers: `.config/nvim/lua/lualine/themes/*.lua`

## Repository rule files
No extra agent-rule files were found during analysis:
- No `.cursorrules`
- No `.cursor/rules/`
- No `.github/copilot-instructions.md`

If any of those files are added later, treat them as higher priority than this document.

## Tech stack
- Language: Lua
- Runtime target: Lua 5.1 semantics inside Neovim
- Host APIs: `vim`, `vim.api`, `vim.fn`, `vim.lsp`, `vim.loop`/`vim.uv`
- Plugin manager: `lazy.nvim`
- Base distro: AstroNvim v5
- Formatter: `stylua`
- Linter: `selene`
- `.luarc.json` disables built-in formatting, so Stylua is authoritative

## Working directory
Run commands from `.config/nvim` unless a command explicitly needs the repo root.

## Build, lint, and test commands
There is no traditional build step for this Neovim config. Use formatting, linting, and headless startup checks instead.

### Formatting
- Format everything: `stylua .`
- Check formatting only: `stylua --check .`
- Format one file: `stylua lua/plugins/lualine.lua`

### Linting
- Lint everything: `selene .`
- Lint one file: `selene lua/plugins/user.lua`

### Validation / smoke tests
- Basic startup smoke test: `nvim --headless "+qa"`
- Sync plugins, then start and quit: `nvim --headless "+Lazy! sync" "+qa"`
- Run health checks headlessly: `nvim --headless "+checkhealth" "+qa"`

### Single-test guidance
There is no checked-in automated test suite right now.
Observed during analysis:
- No `tests/` directory
- No `spec/` directory
- No Plenary test harness in source
- No Makefile/npm/just wrapper with test targets

So there is no true "run one unit test" command to document today.
Use the closest targeted verification instead:
- One file static check: `stylua --check path/to/file.lua && selene path/to/file.lua`
- One feature runtime check: open `nvim` and exercise the affected workflow manually
- Plugin-load regression check: `nvim --headless "+qa"`

If a real test harness is added later, update this file with exact whole-suite and single-test commands.

## Recommended validation sequence
For most edits in `.config/nvim`:
1. `stylua --check .`
2. `selene .`
3. `nvim --headless "+qa"`

For risky bootstrap or plugin-manager changes:
1. `stylua --check .`
2. `selene .`
3. `nvim --headless "+Lazy! sync" "+qa"`
4. Open `nvim` interactively and verify the changed feature

## Style sources
These conventions come from checked-in files and existing code:
- `.config/nvim/.stylua.toml`
- `.config/nvim/selene.toml`
- `.config/nvim/.luarc.json`
- Existing Lua files under `.config/nvim/lua/`

## Formatting conventions
- Use spaces, not tabs
- Indent with 2 spaces
- Prefer max line width 120
- Use Unix line endings
- Prefer double quotes when Stylua chooses
- Omit unnecessary call parentheses when surrounding code already does so
- Let Stylua decide the final layout instead of hand-aligning tables
- Keep plugin spec tables readable, not over-compressed

## File organization
- Put plugin specs in `.config/nvim/lua/plugins/<feature>.lua`
- Keep bootstrap logic minimal in `init.lua` and `lazy_setup.lua`
- Keep one coherent concern per file when practical
- Put editor-wide late tweaks in `polish.lua`
- Keep theme-specific logic in theme/helper files instead of unrelated plugin specs

## Imports and module usage
- Use `require "module"` or `require("module")`; match the file you are editing
- Prefer local aliases for reused modules, e.g. `local opt = vim.opt`
- Require optional or fragile modules close to where they are used
- Use `pcall(require, "...")` for optional integrations
- Do not eagerly require optional plugins at top level unless startup depends on them
- Plugin modules should usually return spec tables directly with `return { ... }`

## Types and annotations
- Preserve existing EmmyLua/LuaLS annotations like `---@type LazySpec`
- Add annotations when they clarify AstroNvim option tables or non-obvious APIs
- Avoid noisy annotations for trivial locals
- Do not rely on LuaLS formatting; `.luarc.json` disables it

## Naming conventions
- Use `snake_case` for locals and helper functions
- Prefer descriptive names over custom abbreviations
- Name plugin files after the feature or plugin they configure
- Use verb phrases for actions, e.g. `open_git_diff`
- Use `get_` only for functions that actually compute or return derived data

## Plugin spec conventions
- Follow AstroNvim/Lazy idioms already present in the repo
- Top-level files usually return one spec table or a list of spec tables
- Prefer `opts = { ... }` for declarative config
- Use `config = function()` only when setup needs logic or branching
- Keep fields like `opts`, `config`, `init`, `event`, `dependencies`, `cond`, and `lazy` explicit when useful
- When extending AstroNvim defaults, avoid replacing behavior unless intentional

## Error handling and resilience
- Fail gracefully for optional dependencies
- Prefer `pcall` around optional `require` calls and non-critical integrations
- Provide fallbacks when a plugin may be absent
- For bootstrap-critical failures, surface a clear error and exit early
- Avoid silently swallowing unexpected errors
- Preserve early-return stubs such as `if true then return {} end` unless intentionally activating them

## Neovim API usage
- Prefer modern Neovim Lua APIs over Vimscript when a Lua API exists
- Use `vim.api.nvim_*` for API calls
- Use `vim.opt` and `vim.opt_local` for options
- Use `vim.g` for plugin globals and Vim globals
- Prefer `vim.filetype.add` over ad hoc filetype hacks
- Keep shell calls limited and justified

## Comments and documentation
- Keep comments concise and useful
- Preserve still-relevant AstroNvim template comments
- Do not add comments for obvious assignments
- Add a short comment for non-obvious workarounds or environment-specific behavior
- Keep commented-out example code only when it is intentionally retained as a template

## Editing guidance
- Preserve user changes outside the requested task
- Prefer small, localized edits over broad rewrites
- Do not delete disabled template files just because they are inactive
- If you activate a stubbed file, make sure the result is complete and validated
- Re-run formatting, linting, and smoke checks after meaningful changes

## Repo-specific facts
- `stylua` is installed via Mason config
- `selene` targets the `neovim` standard library
- Treesitter parsers are managed in `lua/plugins/treesitter.lua`
- AstroCommunity imports are centralized in `lua/community.lua`
- `lua/plugins/astrolsp.lua` enables format-on-save for Lua, while `lua/polish.lua` sets `vim.g.autoformat = false`; verify intent before changing formatting behavior

## When unsure
- Follow the nearest existing pattern
- Prefer AstroNvim/Lazy conventions over inventing custom structure
- Keep startup stable and optional integrations defensive
- Update this file if you introduce a real build or test workflow
