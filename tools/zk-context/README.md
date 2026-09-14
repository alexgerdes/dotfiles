# ZK Context

A small Swift app providing macOS Core Location and current weather for zk notes.
This directory is the source of truth for the helper; build it separately on each
Mac. Only source files belong in Git. Builds, location caches, and permissions
stay local to each computer.

## Install on another Mac

Requires macOS and Apple's Xcode Command Line Tools (`xcode-select --install` if
they are missing). No third-party Swift packages or weather API key are needed.

```sh
cd ~/Repos/dotfiles
make -C tools/zk-context install
```

This compiles for the current Mac's architecture, creates an app bundle with its
location usage descriptions, signs it locally, and installs it at
`~/Applications/ZK Context.app`. This is the path used by the repository's
`.config/nvim/lua/zk_context.lua`. Make sure that Neovim config is linked/installed
on the other Mac too, then restart Neovim.

On first use, allow location access for **ZK Context**. If necessary, enable it in
System Settings → Privacy & Security → Location Services. Permission is per Mac;
it is not synced through Git. Rebuilding an ad-hoc signed app may require approval
again. The helper is a local build, not a notarized distribution.

To request location directly:

```sh
"$HOME/Applications/ZK Context.app/Contents/MacOS/zk-context" --refresh
```

The command prints JSON, including coordinates. Without `--refresh`, it may use
the ten-minute cache. `make install` can also be rerun after pulling source changes.

## Behavior

Core Location requests kilometer accuracy; Apple's geocoder supplies a place
name. Open-Meteo supplies weather and Celsius temperature using coordinates
rounded to two decimal places. Note contents are never sent to either service.
Weather data: [Open-Meteo](https://open-meteo.com/), CC BY 4.0.

The cache is `~/.cache/zk/context.json`, with its lifetime measured from the
location observation timestamp. There is no resident process or periodic location
tracking. A request has a twenty-second overall timeout and an eight-second
weather timeout. Location can still succeed if weather fails.

The Swift JSON contains internal accuracy and timestamp fields for caching and
diagnostics. Neovim writes only `date`, `tags`, `location`, `weather`, and
`temperature_c` into notes, with coordinates in parentheses after the place name.
The templates live in each synced notebook's `.zk/templates/` folder.

New notes open immediately and fill empty context fields asynchronously. Edited
values are preserved. Clean buffers are saved automatically; unsaved user edits
remain unsaved. Historical notes are excluded. `:ZkContextRefresh` retries empty
fields in an eligible note dated today and bypasses the cache.

## Build and verification

```sh
make -C tools/zk-context build      # compile and sign under .build/
make -C tools/zk-context check      # validate the bundle and signature
make -C tools/zk-context test       # mocked Neovim integration checks
make -C tools/zk-context test-live  # installed app, actual location or cache
```

Tests require Neovim on PATH. Mocked tests cover background updates, preservation
of user text and metadata, coordinate formatting, saving, and historical-note
protection. The live test creates a temporary notebook and measures note opening
and metadata completion; it can trigger a macOS location permission request.

The build uses Swift 5 language mode with the installed SDK. CLGeocoder still
works but produces deprecation warnings with macOS 26 SDKs.
