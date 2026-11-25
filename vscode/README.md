# VS Code

User-level VS Code files, symlinked into VS Code's config directory.

| File | Purpose |
| --- | --- |
| `keybindings.json` | Custom keybindings, incl. `cmd+shift+f` for the `code-rg` task |
| `tasks.json` | User task `code-rg`: live ripgrep + fzf search that opens the match in VS Code |

## Install

```sh
U="$HOME/Library/Application Support/Code/User"
for f in keybindings.json tasks.json; do
  ln -sf "$HOME/Repos/dotfiles/vscode/$f" "$U/$f"
done
```

Back up any existing files in `$U` first; `ln -sf` replaces them.

## Requirements

- The `code-rg` shell function from `~/.zshrc.local` (the task runs it via `zsh -ic`)
- `rg`, `fzf`, `bat`, and the `code` CLI on `PATH`

## Neovim integration

The VS Code Neovim extension loads `.config/nvim/lua/vscode_setup.lua`
(set `"vscode-neovim.neovimClean": false`). In that config:

- `<Leader>fw` runs the `code-rg` task
- `<Leader>gg` opens Lazygit (`chaitanyashahare.lazygit` extension)
