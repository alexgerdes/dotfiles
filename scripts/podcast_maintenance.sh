#!/bin/bash

# Keep completed recordings below a fixed size and rebuild all podcast feeds.
#
# Usage:
#   ./podcast_maintenance.sh [--dry-run]
#
# Cron example (daily at 23:30):
#   30 23 * * * /absolute/path/podcast_maintenance.sh >> /absolute/path/radio_logger.log 2>&1

set -u

# Configuration
readonly MAX_MUSIC_DIR_BYTES=4000000000
readonly MUSIC_DIR="$HOME/radiopod/music"
readonly PODCAST_CONFIG="$HOME/.config/radio_logger/podcast.conf"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
readonly SCRIPT_DIR
readonly MAINTENANCE_SCRIPT="$SCRIPT_DIR/podcast_maintenance.py"

dry_run=0
if [ "$#" -gt 1 ] || { [ "$#" -eq 1 ] && [ "$1" != "--dry-run" ]; }; then
    printf 'Usage: %s [--dry-run]\n' "$(basename "$0")" >&2
    exit 64
elif [ "$#" -eq 1 ]; then
    dry_run=1
fi

if [ ! -r "$PODCAST_CONFIG" ]; then
    printf 'Error: podcast config is not readable: %s\n' "$PODCAST_CONFIG" >&2
    exit 78
fi

if ! "$BASH" -n "$PODCAST_CONFIG"; then
    printf 'Error: podcast config has invalid shell syntax: %s\n' "$PODCAST_CONFIG" >&2
    exit 78
fi

unset PODCAST_ARTWORK_URL PODCAST_BASE_URL PODCAST_FEED_DIR PODCAST_LANGUAGE
if ! . "$PODCAST_CONFIG"; then
    printf 'Error: podcast config could not be loaded: %s\n' "$PODCAST_CONFIG" >&2
    exit 78
fi

if [ -z "${PODCAST_ARTWORK_URL:-}" ] || [ -z "${PODCAST_BASE_URL:-}" ] || [ -z "${PODCAST_FEED_DIR:-}" ]; then
    printf 'Error: podcast config is missing PODCAST_ARTWORK_URL, PODCAST_BASE_URL, or PODCAST_FEED_DIR.\n' >&2
    exit 78
fi

if [ "${PODCAST_BASE_URL#https://}" = "$PODCAST_BASE_URL" ] \
    || [ "${PODCAST_ARTWORK_URL#https://}" = "$PODCAST_ARTWORK_URL" ]; then
    printf 'Error: podcast base and artwork URLs must use HTTPS.\n' >&2
    exit 78
fi

if [ ! -r "$MAINTENANCE_SCRIPT" ]; then
    printf 'Error: podcast maintenance script is not readable: %s\n' "$MAINTENANCE_SCRIPT" >&2
    exit 69
fi

if ! PYTHON_BIN=$(command -v python3); then
    printf 'Error: python3 was not found in PATH.\n' >&2
    exit 69
fi
readonly PYTHON_BIN

if ! command -v ffprobe >/dev/null 2>&1; then
    printf 'Error: ffprobe was not found in PATH.\n' >&2
    exit 69
fi

PODCAST_LANGUAGE=${PODCAST_LANGUAGE:-nl-NL}
readonly PODCAST_ARTWORK_URL PODCAST_BASE_URL PODCAST_FEED_DIR PODCAST_LANGUAGE

maintenance_args=(
    "$MAINTENANCE_SCRIPT"
    --music-dir "$MUSIC_DIR"
    --feed-dir "$PODCAST_FEED_DIR"
    --base-url "$PODCAST_BASE_URL"
    --artwork-url "$PODCAST_ARTWORK_URL"
    --language "$PODCAST_LANGUAGE"
    --max-bytes "$MAX_MUSIC_DIR_BYTES"
)

if [ "$dry_run" -eq 1 ]; then
    maintenance_args+=(--dry-run)
fi

"$PYTHON_BIN" "${maintenance_args[@]}"
