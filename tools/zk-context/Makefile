SHELL := /bin/sh
.DEFAULT_GOAL := build

# Override only if your Neovim helper path is also changed.
APP_DIR ?= $(HOME)/Applications/ZK Context.app
BUILD_APP := .build/ZK Context.app

.PHONY: build install check test test-live check-platform

check-platform:
	@test "$$(uname -s)" = Darwin || { echo 'ZK Context requires macOS.' >&2; exit 1; }
	@xcrun --find swiftc >/dev/null

build: .build/.built

.build/.built: Context.swift Info.plist Makefile | check-platform
	mkdir -p "$(BUILD_APP)/Contents/MacOS"
	cp Info.plist "$(BUILD_APP)/Contents/Info.plist"
	xcrun swiftc -swift-version 5 -module-name ZKContext Context.swift \
		-o "$(BUILD_APP)/Contents/MacOS/zk-context" -framework AppKit -framework CoreLocation
	codesign --force --sign - "$(BUILD_APP)"
	codesign --verify --strict "$(BUILD_APP)"
	touch "$@"

check: build
	plutil -lint "$(BUILD_APP)/Contents/Info.plist"
	codesign --verify --strict "$(BUILD_APP)"
	@test -x "$(BUILD_APP)/Contents/MacOS/zk-context"

install: check
	mkdir -p "$(APP_DIR)"
	ditto "$(BUILD_APP)" "$(APP_DIR)"
	codesign --verify --strict "$(APP_DIR)"
	@printf 'Installed: %s\n' "$(APP_DIR)"

# Mocked editor checks do not request location access.
test:
	nvim --headless -u NONE -l verify.lua

# Explicit opt-in: uses the installed app and may request location permission.
test-live:
	nvim --headless -u NONE -l verify-live.lua
