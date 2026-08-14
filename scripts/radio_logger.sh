#!/bin/bash

# Record a radio stream for a fixed duration.
#
# Usage:
#   ./radio_logger.sh STREAM_URL DURATION SHOW_NAME
#
set -u

# Configuration
readonly OUTPUT_DIR="$HOME/Downloads/Radio"
readonly TEMP_DIR="/tmp"

usage() {
    printf 'Usage: %s STREAM_URL DURATION SHOW_NAME\n' "$(basename "$0")" >&2
    printf 'Example: %s "https://example.com/live.aac" "03:00:00" "Veronica"\n' "$(basename "$0")" >&2
}

if [ "$#" -ne 3 ]; then
    usage
    exit 64
fi

stream_url=$1
duration=$2
show_name=$3

if [ -z "$stream_url" ] || [ -z "$duration" ] || [ -z "$show_name" ]; then
    printf 'Error: none of the arguments may be empty.\n' >&2
    usage
    exit 64
fi

# Keep the supplied title recognizable while making it safe for a filename.
safe_show_name=$(printf '%s' "$show_name" \
    | tr '[:space:]' '_' \
    | tr -cd '[:alnum:]_.-')

if [ -z "$safe_show_name" ]; then
    printf 'Error: the show name must contain at least one letter or number.\n' >&2
    exit 64
fi

mkdir -p "$OUTPUT_DIR" || {
    printf 'Error: could not create output directory: %s\n' "$OUTPUT_DIR" >&2
    exit 73
}

if ! FFMPEG_BIN=$(which ffmpeg 2>/dev/null); then
    printf 'Error: ffmpeg was not found. Install it and ensure it is in PATH.\n' >&2
    exit 69
fi
readonly FFMPEG_BIN

if [ ! -x "$FFMPEG_BIN" ]; then
    printf 'Error: ffmpeg is not executable: %s\n' "$FFMPEG_BIN" >&2
    exit 69
fi

if ! FFPROBE_BIN=$(which ffprobe 2>/dev/null); then
    printf 'Error: ffprobe was not found. Install it and ensure it is in PATH.\n' >&2
    exit 69
fi
readonly FFPROBE_BIN

if [ ! -x "$FFPROBE_BIN" ]; then
    printf 'Error: ffprobe is not executable: %s\n' "$FFPROBE_BIN" >&2
    exit 69
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
output_base="$OUTPUT_DIR/${safe_show_name}_${timestamp}"

mkdir -p "$TEMP_DIR" || {
    printf 'Error: could not create temporary directory: %s\n' "$TEMP_DIR" >&2
    exit 73
}

# Keep the intermediate file outside protected macOS folders such as Downloads.
# launchd may be allowed to create a recording there through ffmpeg while macOS
# still prevents /bin/rm from deleting it afterward.
temporary_file="$TEMP_DIR/${safe_show_name}_${timestamp}_$$.part.mka"

printf 'Recording "%s"...\n' "$show_name"

"$FFMPEG_BIN" \
    -nostdin \
    -i "$stream_url" \
    -y \
    -t "$duration" \
    -map 0:a:0 \
    -c copy \
    -f matroska \
    "$temporary_file"

status=$?
if [ "$status" -ne 0 ]; then
    printf 'Error: ffmpeg stopped with exit status %s.\n' "$status" >&2
    printf 'Any partial recording has been kept at: %s\n' "$temporary_file" >&2
    exit "$status"
fi

codec_name=$("$FFPROBE_BIN" \
    -v error \
    -select_streams a:0 \
    -show_entries stream=codec_name \
    -of default=noprint_wrappers=1:nokey=1 \
    "$temporary_file")

case "$codec_name" in
    aac)
        output_extension=aac
        output_format=adts
        ;;
    mp3)
        output_extension=mp3
        output_format=mp3
        ;;
    *)
        output_file="${output_base}.mka"
        mv "$temporary_file" "$output_file" || exit 73
        printf 'Warning: codec "%s" was kept in a Matroska audio file.\n' "$codec_name" >&2
        printf 'Finished recording: %s\n' "$output_file"
        exit 0
        ;;
esac

output_file="${output_base}.${output_extension}"

# Change only the container; the recorded audio is not re-encoded.
"$FFMPEG_BIN" \
    -nostdin \
    -i "$temporary_file" \
    -y \
    -map 0:a:0 \
    -c copy \
    -f "$output_format" \
    "$output_file"

status=$?
if [ "$status" -ne 0 ]; then
    printf 'Error: could not create the final .%s file.\n' "$output_extension" >&2
    printf 'The recording has been kept at: %s\n' "$temporary_file" >&2
    exit "$status"
fi

if ! rm -f "$temporary_file"; then
    printf 'Error: could not delete temporary recording: %s\n' "$temporary_file" >&2
    exit 74
fi

printf 'Finished recording: %s\n' "$output_file"
