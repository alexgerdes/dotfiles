# Work and personal notes

Work notebook: `~/OneDrive - Chalmers/Journal`

Personal notebook: `~/Library/Mobile Documents/com~apple~CloudDocs/Journal`
(Finder: iCloud Drive → Journal)

Each notebook contains:

- `notes/`: regular notes with a stable random ID and readable title in the filename.
- `daily/YYYY-MM-DD.md`: one note per day; opening it again preserves its contents.
- `.zk/config.toml`: notebook settings.
- `.zk/templates/`: editable templates for regular and daily notes.

## Start

Restart Neovim and open a new terminal, or run `source ~/.zshrc` in your current terminal.

Use `zwd` for today's work note and `zpd` for today's personal note.
Inside Neovim, use `Space z w` and `Space z p` for the same actions.

## Terminal shortcuts

| Command | Action |
| --- | --- |
| `zwd` / `zpd` | Open or create today's work / personal note |
| `zwn My note title` / `zpn My note title` | Create a regular work / personal note |
| `zkw` / `zkp` | Browse work / personal notes with fzf |
| `zkw search "search terms"` | Search work note contents |
| `zkp search "search terms"` | Search personal note contents |
| `zkw days` / `zkp days` | Browse daily notes, newest first |
| `zkw recent` / `zkp recent` | Browse the 30 most recently modified notes |
| `zkw last` / `zkp last` | Open the most recently modified note |
| `zkw tags` / `zkp tags` | List tags |
| `zkw orphans` / `zkp orphans` | Find notes with no incoming links |
| `zkw reindex` / `zkp reindex` | Rebuild the index after external changes if needed |
| `cdwork` / `cdpersonal` | Change directory to a notebook |

`zkw` and `zkp` also accept native zk commands and options.
For example, `zkw daily --date yesterday` opens yesterday's work note.
Use `zkw n "My title"` to create a titled note; `new` remains zk's native command.
With native `new`, paths are relative to the working directory, so use `cdwork`
followed by `zk new notes --title "My title"`, or use the shortcuts above.

Plain `zk` discovers the notebook from your working directory, falling back to personal.
Shared aliases are in `~/.config/zk/config.toml`; shell shortcuts are in `~/.zshrc.local`.

## Neovim shortcuts

Your leader is Space. Press `Space z` to see the available actions.

| Keys | Action |
| --- | --- |
| `Space z w` / `Space z p` | Today's work / personal note |
| `Space z W` / `Space z P` | Browse work / personal notes |
| `Space z d` | Today's note in the current notebook |
| `Space z n` | Create a regular note, prompting for a title |
| `Space z f` | Find notes by title with Snacks picker |
| `Space z s` | Search note contents |
| `Space z t` | Find notes by tag |
| `Space z b` / `Space z l` | Backlinks / outgoing links |
| `Space z i` | Insert a link; in Visual mode, link the selected text |

`:ZkWork`, `:ZkPersonal`, and `:ZkDaily` also open today's note.
The current notebook is determined by the open file, then the working directory,
then the personal default. Opening a work note therefore makes subsequent note
creation and searches use work, even if your shell started elsewhere.

zk's language server attaches to notebook Markdown files for link completion,
navigation, hover, and broken-link diagnostics. Use `gd` to follow a note link
and `Ctrl-o` to return. Regular Markdown links are used for portability.

## A small daily workflow

New notes have just `date`, `tags`, `location`, `weather`, and `temperature_c` in
frontmatter. Coordinates appear in parentheses after the location name, as
`Place (latitude, longitude)`. The Swift Core Location helper runs asynchronously;
opening the note does not wait. A cache up to ten minutes old avoids repeat
lookups. This works with Neovim shortcuts and terminal aliases that open Neovim.

Metadata fills only empty fields. If you have unsaved edits, save normally to
persist the new metadata too. Existing notes and historical imports are untouched.
Use `:ZkContextRefresh` to retry empty fields in today's eligible note after a
lookup failure. Source, build instructions, and technical details:
[`tools/zk-context`](../../tools/zk-context/README.md) in the dotfiles repository.

1. Open today's note and capture tasks, observations, and rough ideas.
2. When an idea deserves its own note, use `Space z n` and give it a descriptive title.
3. Return to your daily note and use `Space z i` to link the new note.
4. Add tags in frontmatter, such as `tags: [research, teaching]`, when useful.
5. Review backlinks to connect related ideas within each notebook.

Work and personal notebooks have independent indexes and searches.
Templates and Markdown notes live inside their respective cloud folders.
Your existing journal.nvim configuration remains available separately; these
shortcuts use zk and its `daily/` layout.

References: https://zk-org.github.io/zk/tips/daily-journal.html and
https://github.com/zk-org/zk-nvim
