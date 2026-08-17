#!/bin/bash

# Record a radio stream for a fixed duration.
#
# Usage:
#   ./radio_logger.sh STREAM_URL DURATION STATION_NAME SHOW_NAME
#
# Cron example:
#   0 18 * * 5 /absolute/path/radio_logger.sh "https://example.com/live.mp3" "04:00:00" "Veronica" "Show Name" >> /absolute/path/radio_logger.log 2>&1
#
set -u

# Configuration
OUTPUT_DIR="$HOME/radiopod/music/"
readonly TEMP_DIR="/tmp"
readonly PODCAST_CONFIG="$HOME/.config/radio_logger/podcast.conf"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
readonly SCRIPT_DIR
readonly PODCAST_GENERATOR="$SCRIPT_DIR/podcast_feed.py"

usage() {
    printf 'Usage: %s STREAM_URL DURATION STATION_NAME SHOW_NAME\n' "$(basename "$0")" >&2
    printf 'Example: %s "https://example.com/live.mp3" "04:00:00" "Veronica" "Show Name"\n' \
        "$(basename "$0")" >&2
}

if [ "$#" -ne 4 ]; then
    usage
    exit 64
fi

stream_url=$1
duration=$2
station_name=$3
show_name=$4

if [ -z "$stream_url" ] || [ -z "$duration" ] || [ -z "$station_name" ] || [ -z "$show_name" ]; then
    printf 'Error: none of the arguments may be empty.\n' >&2
    usage
    exit 64
fi

# Keep the supplied names recognizable while making them safe for a filename.
safe_station_name=$(printf '%s' "$station_name" \
    | tr '[:space:]' '_' \
    | tr -cd '[:alnum:]_.-')

safe_show_name=$(printf '%s' "$show_name" \
    | tr '[:space:]' '_' \
    | tr -cd '[:alnum:]_.-')

if [ -z "$safe_station_name" ]; then
    printf 'Error: the station name must contain at least one letter or number.\n' >&2
    exit 64
fi

if [ -z "$safe_show_name" ]; then
    printf 'Error: the show name must contain at least one letter or number.\n' >&2
    exit 64
fi

mkdir -p "$OUTPUT_DIR" || {
    printf 'Error: could not create output directory: %s\n' "$OUTPUT_DIR" >&2
    exit 73
}

if ! FFMPEG_BIN=$(command -v ffmpeg); then
    printf 'Error: ffmpeg was not found in PATH.\n' >&2
    exit 69
fi
readonly FFMPEG_BIN

if [ ! -x "$FFMPEG_BIN" ]; then
    printf 'Error: ffmpeg is not executable: %s\n' "$FFMPEG_BIN" >&2
    exit 69
fi

podcast_enabled=0
if [ ! -r "$PODCAST_CONFIG" ]; then
    printf 'Warning: podcast config is not readable; feed generation is disabled: %s\n' "$PODCAST_CONFIG" >&2
else
    unset PODCAST_ARTWORK_URL PODCAST_BASE_URL PODCAST_FEED_DIR PODCAST_LANGUAGE
    if ! "$BASH" -n "$PODCAST_CONFIG"; then
        printf 'Warning: podcast config has invalid shell syntax; feed generation is disabled: %s\n' \
            "$PODCAST_CONFIG" >&2
    elif ! . "$PODCAST_CONFIG"; then
        printf 'Warning: podcast config could not be loaded; feed generation is disabled: %s\n' \
            "$PODCAST_CONFIG" >&2
    elif [ -z "${PODCAST_ARTWORK_URL:-}" ] || [ -z "${PODCAST_BASE_URL:-}" ] || [ -z "${PODCAST_FEED_DIR:-}" ]; then
        printf 'Warning: podcast config is missing PODCAST_ARTWORK_URL, PODCAST_BASE_URL, or PODCAST_FEED_DIR; feed generation is disabled.\n' >&2
    elif [ "${PODCAST_BASE_URL#https://}" = "$PODCAST_BASE_URL" ]; then
        printf 'Warning: PODCAST_BASE_URL must use HTTPS; feed generation is disabled.\n' >&2
    elif [ "${PODCAST_ARTWORK_URL#https://}" = "$PODCAST_ARTWORK_URL" ]; then
        printf 'Warning: PODCAST_ARTWORK_URL must use HTTPS; feed generation is disabled.\n' >&2
    elif [ ! -r "$PODCAST_GENERATOR" ]; then
        printf 'Warning: podcast generator is not readable; feed generation is disabled: %s\n' \
            "$PODCAST_GENERATOR" >&2
    elif ! PYTHON_BIN=$(command -v python3); then
        printf 'Warning: python3 was not found in PATH; feed generation is disabled.\n' >&2
    elif ! command -v ffprobe >/dev/null 2>&1; then
        printf 'Warning: ffprobe was not found in PATH; feed generation is disabled.\n' >&2
    else
        PODCAST_LANGUAGE=${PODCAST_LANGUAGE:-nl-NL}
        readonly PODCAST_ARTWORK_URL PODCAST_BASE_URL PODCAST_FEED_DIR PODCAST_LANGUAGE PYTHON_BIN
        podcast_enabled=1
    fi
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
recording_date=$(date '+%Y-%m-%d')
recording_datetime=$(date '+%Y-%m-%d %H:%M:%S %Z')
output_base="${OUTPUT_DIR%/}/${safe_station_name}_${safe_show_name}_${timestamp}"

mkdir -p "$TEMP_DIR" || {
    printf 'Error: could not create temporary directory: %s\n' "$TEMP_DIR" >&2
    exit 73
}

# Keep the incomplete recording out of the output directory.
temporary_file="$TEMP_DIR/${safe_station_name}_${safe_show_name}_${timestamp}_$$.part.mp3"

cleanup() {
    exit_status=$?
    trap - EXIT

    if [ "$exit_status" -ne 0 ]; then
        printf 'Recording failure: "%s" on "%s" failed at %s with exit status %s.\n' \
            "$show_name" "$station_name" "$(date '+%Y-%m-%d %H:%M:%S %Z')" "$exit_status" >&2
    fi

    if [ -f "$temporary_file" ]; then
        if rm -f "$temporary_file"; then
            printf 'Removed temporary recording: %s\n' "$temporary_file" >&2
        else
            printf 'Error: could not delete temporary recording: %s\n' "$temporary_file" >&2
        fi
    fi

    exit "$exit_status"
}
trap cleanup EXIT

printf 'Recording "%s" on "%s"...\n' "$show_name" "$station_name"

"$FFMPEG_BIN" \
    -nostdin \
    -i "$stream_url" \
    -y \
    -t "$duration" \
    -map 0:a:0 \
    -c:a libmp3lame \
    -b:a 128k \
    -metadata title="$recording_date - $show_name" \
    -metadata artist="$station_name" \
    -metadata album_artist="$station_name" \
    -metadata album="$show_name" \
    -metadata date="$recording_date" \
    -metadata genre="Radio" \
    -metadata comment="Recorded at $recording_datetime" \
    -id3v2_version 3 \
    -f mp3 \
    "$temporary_file"

status=$?
if [ "$status" -ne 0 ]; then
    printf 'Error: ffmpeg stopped with exit status %s.\n' "$status" >&2
    exit "$status"
fi

output_file="${output_base}.mp3"
mv "$temporary_file" "$output_file" || {
    printf 'Error: could not move the recording to: %s\n' "$output_file" >&2
    exit 73
}

trap - EXIT
printf 'Finished recording: %s\n' "$output_file"

if [ "$podcast_enabled" -eq 1 ]; then
    "$PYTHON_BIN" "$PODCAST_GENERATOR" \
        --music-dir "$OUTPUT_DIR" \
        --feed-dir "$PODCAST_FEED_DIR" \
        --base-url "$PODCAST_BASE_URL" \
        --artwork-url "$PODCAST_ARTWORK_URL" \
        --station "$station_name" \
        --show "$show_name" \
        --language "$PODCAST_LANGUAGE"

    podcast_status=$?
    if [ "$podcast_status" -ne 0 ]; then
        printf 'Error: recording completed, but podcast feed generation failed with exit status %s.\n' \
            "$podcast_status" >&2
        exit "$podcast_status"
    fi
fi
