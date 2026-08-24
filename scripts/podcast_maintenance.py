#!/usr/bin/env python3

"""Prune old radio recordings to a size limit and rebuild podcast feeds."""

import argparse
import shutil
import sys
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import quote

sys.dont_write_bytecode = True

from podcast_feed import (
    Episode,
    PodcastFeedError,
    build_feed,
    normalize_artwork_url,
    normalize_base_url,
    probe_mp3,
    slugify,
    write_feed_atomically,
)


GroupKey = tuple[str, str]


@dataclass
class Recording:
    path: Path
    size: int
    modified_at: datetime
    station_name: str | None = None
    show_name: str | None = None
    episode: Episode | None = None

    @property
    def group_key(self) -> GroupKey | None:
        if not self.station_name or not self.show_name:
            return None
        return self.station_name.casefold(), self.show_name.casefold()


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--music-dir", required=True, type=Path, help="Directory containing recorded MP3 files")
    parser.add_argument("--feed-dir", required=True, type=Path, help="Directory containing generated RSS feeds")
    parser.add_argument("--base-url", required=True, help="Private HTTPS URL prefix for feeds and audio")
    parser.add_argument("--artwork-url", required=True, help="Public HTTPS URL for square podcast artwork")
    parser.add_argument("--language", default="en", help="Podcast language code (default: en)")
    parser.add_argument("--max-bytes", required=True, type=int, help="Maximum combined size of completed MP3 files")
    parser.add_argument("--dry-run", action="store_true", help="Report deletions without changing files or feeds")
    return parser.parse_args()


def format_size(size: int) -> str:
    return f"{size / 1_000_000:.1f} MB"


def scan_recordings(music_dir: Path, base_url: str, ffprobe_bin: str) -> list[Recording]:
    recordings: list[Recording] = []

    for path in sorted(music_dir.glob("*.mp3")):
        try:
            file_stat = path.stat()
        except OSError as error:
            print(f"Warning: could not inspect recording {path}: {error}", file=sys.stderr)
            continue

        recording = Recording(
            path=path,
            size=file_stat.st_size,
            modified_at=datetime.fromtimestamp(file_stat.st_mtime, timezone.utc),
        )

        try:
            tags, duration_seconds = probe_mp3(ffprobe_bin, path)
        except PodcastFeedError as error:
            print(f"Warning: recording has no usable podcast metadata: {path}: {error}", file=sys.stderr)
            recordings.append(recording)
            continue

        station_name = tags.get("artist") or tags.get("album_artist")
        show_name = tags.get("album")
        if not station_name or not show_name:
            print(f"Warning: recording is missing station or show metadata: {path}", file=sys.stderr)
            recordings.append(recording)
            continue

        recording.station_name = station_name
        recording.show_name = show_name
        recording.episode = Episode(
            path=path,
            title=tags.get("title", path.stem),
            description=tags.get("comment", f"Recorded from {station_name}."),
            published_at=recording.modified_at,
            duration_seconds=duration_seconds,
            enclosure_url=f"{base_url}/audio/{quote(path.name, safe='')}",
        )
        recordings.append(recording)

    return recordings


def newest_recording_per_show(recordings: list[Recording]) -> set[Path]:
    newest: dict[GroupKey, Recording] = {}

    for recording in recordings:
        group_key = recording.group_key
        if not group_key:
            continue
        previous = newest.get(group_key)
        if not previous or (recording.modified_at, recording.path.name) > (previous.modified_at, previous.path.name):
            newest[group_key] = recording

    return {recording.path for recording in newest.values()}


def prune_recordings(
    recordings: list[Recording],
    max_bytes: int,
    dry_run: bool,
) -> tuple[list[Recording], int, int, bool]:
    initial_size = sum(recording.size for recording in recordings)
    target_size = initial_size
    protected_paths = newest_recording_per_show(recordings)
    deleted_paths: set[Path] = set()
    deletion_failed = False

    for recording in sorted(recordings, key=lambda item: (item.modified_at, item.path.name)):
        if target_size <= max_bytes:
            break
        if recording.path in protected_paths:
            continue

        action = "Would delete" if dry_run else "Deleting"
        print(f"{action} oldest recording: {recording.path} ({format_size(recording.size)})")

        if not dry_run:
            try:
                recording.path.unlink()
            except OSError as error:
                deletion_failed = True
                print(f"Error: could not delete recording {recording.path}: {error}", file=sys.stderr)
                continue

        deleted_paths.add(recording.path)
        target_size -= recording.size

    remaining = [recording for recording in recordings if recording.path not in deleted_paths]
    return remaining, initial_size, target_size, deletion_failed


def rebuild_feeds(
    recordings_before: list[Recording],
    recordings_after: list[Recording],
    feed_dir: Path,
    base_url: str,
    artwork_url: str,
    language: str,
) -> bool:
    names_before: dict[GroupKey, tuple[str, str]] = {}
    episodes_after: dict[GroupKey, list[Episode]] = {}
    names_after: dict[GroupKey, tuple[str, str]] = {}
    failed = False

    for recording in recordings_before:
        if recording.group_key and recording.station_name and recording.show_name:
            names_before[recording.group_key] = recording.station_name, recording.show_name

    for recording in recordings_after:
        if not recording.group_key or not recording.station_name or not recording.show_name or not recording.episode:
            continue
        names_after[recording.group_key] = recording.station_name, recording.show_name
        episodes_after.setdefault(recording.group_key, []).append(recording.episode)

    for group_key, episodes in sorted(episodes_after.items()):
        station_name, show_name = names_after[group_key]
        episodes.sort(key=lambda episode: episode.published_at, reverse=True)
        feed_filename = f"{slugify(station_name)}-{slugify(show_name)}.xml"
        feed_url = f"{base_url}/feeds/{quote(feed_filename, safe='')}"
        feed = build_feed(station_name, show_name, language, feed_url, artwork_url, episodes)
        destination = feed_dir / feed_filename

        try:
            write_feed_atomically(feed, destination)
        except OSError as error:
            failed = True
            print(f"Error: could not rebuild podcast feed {destination}: {error}", file=sys.stderr)
            continue

        print(f"Rebuilt podcast feed: {destination}")

    for group_key in sorted(names_before.keys() - names_after.keys()):
        station_name, show_name = names_before[group_key]
        destination = feed_dir / f"{slugify(station_name)}-{slugify(show_name)}.xml"
        try:
            destination.unlink(missing_ok=True)
        except OSError as error:
            failed = True
            print(f"Error: could not remove stale podcast feed {destination}: {error}", file=sys.stderr)
        else:
            print(f"Removed stale podcast feed: {destination}")

    return failed


def main() -> int:
    args = parse_args()

    try:
        base_url = normalize_base_url(args.base_url)
        artwork_url = normalize_artwork_url(args.artwork_url)
        music_dir = args.music_dir.expanduser().resolve()
        feed_dir = args.feed_dir.expanduser().resolve()
        if not music_dir.is_dir():
            raise PodcastFeedError(f"music directory does not exist: {music_dir}")
        if args.max_bytes <= 0:
            raise PodcastFeedError("maximum directory size must be greater than zero")

        ffprobe_bin = shutil.which("ffprobe")
        if not ffprobe_bin:
            raise PodcastFeedError("ffprobe was not found in PATH")
    except PodcastFeedError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    print(f"Podcast maintenance started at {datetime.now().astimezone().strftime('%Y-%m-%d %H:%M:%S %Z')}")
    recordings = scan_recordings(music_dir, base_url, ffprobe_bin)
    remaining, initial_size, final_size, deletion_failed = prune_recordings(recordings, args.max_bytes, args.dry_run)
    print(f"Music directory size: {format_size(initial_size)} -> {format_size(final_size)}")

    if final_size > args.max_bytes:
        print(
            "Error: the directory remains above its limit because protected recordings or deletion errors prevented cleanup.",
            file=sys.stderr,
        )
        deletion_failed = True

    if args.dry_run:
        print("Dry run complete; no recordings or feeds were changed.")
        return 1 if deletion_failed else 0

    feed_failed = rebuild_feeds(recordings, remaining, feed_dir, base_url, artwork_url, args.language)
    return 1 if deletion_failed or feed_failed else 0


if __name__ == "__main__":
    sys.exit(main())
