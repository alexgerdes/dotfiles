#!/usr/bin/env python3

"""Generate a podcast RSS feed from tagged radio recordings."""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata
import xml.etree.ElementTree as ET
from dataclasses import dataclass
from datetime import datetime, timezone
from email.utils import format_datetime
from pathlib import Path
from urllib.parse import quote, urlparse

ATOM_NAMESPACE = "http://www.w3.org/2005/Atom"
ITUNES_NAMESPACE = "http://www.itunes.com/dtds/podcast-1.0.dtd"

ET.register_namespace("atom", ATOM_NAMESPACE)
ET.register_namespace("itunes", ITUNES_NAMESPACE)


class PodcastFeedError(Exception):
    """Raised when the feed cannot be generated."""


@dataclass
class Episode:
    path: Path
    title: str
    description: str
    published_at: datetime
    duration_seconds: int
    enclosure_url: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--music-dir", required=True, type=Path, help="Directory containing recorded MP3 files")
    parser.add_argument("--feed-dir", required=True, type=Path, help="Directory in which to write RSS feeds")
    parser.add_argument("--base-url", required=True, help="Private HTTPS URL prefix for feeds and audio")
    parser.add_argument("--station", required=True, help="Station name stored in the MP3 artist tag")
    parser.add_argument("--show", required=True, help="Show name stored in the MP3 album tag")
    parser.add_argument("--language", default="en", help="Podcast language code (default: en)")
    return parser.parse_args()


def slugify(value: str) -> str:
    normalized = unicodedata.normalize("NFKD", value).encode("ascii", "ignore").decode("ascii")
    slug = re.sub(r"[^a-z0-9]+", "-", normalized.lower()).strip("-")
    if slug:
        return slug
    return hashlib.sha256(value.encode("utf-8")).hexdigest()[:12]


def normalize_base_url(value: str) -> str:
    base_url = value.rstrip("/")
    parsed = urlparse(base_url)
    if parsed.scheme != "https" or not parsed.netloc or parsed.query or parsed.fragment:
        raise PodcastFeedError("base URL must be an HTTPS URL without a query string or fragment")
    return base_url


def probe_mp3(ffprobe_bin: str, path: Path) -> tuple[dict[str, str], int]:
    command = [
        ffprobe_bin,
        "-v",
        "error",
        "-show_entries",
        "format=duration:format_tags=title,artist,album_artist,album,date,genre,comment",
        "-of",
        "json",
        str(path),
    ]

    try:
        result = subprocess.run(command, check=True, capture_output=True, text=True, timeout=30)
        payload = json.loads(result.stdout)
        format_data = payload["format"]
        duration_seconds = max(0, round(float(format_data["duration"])))
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, KeyError, TypeError, ValueError, json.JSONDecodeError) as error:
        raise PodcastFeedError(f"could not read MP3 metadata: {error}") from error

    raw_tags = format_data.get("tags", {})
    tags = {str(key).lower(): str(value) for key, value in raw_tags.items()}
    return tags, duration_seconds


def collect_episodes(
    music_dir: Path,
    base_url: str,
    station_name: str,
    show_name: str,
    ffprobe_bin: str,
) -> list[Episode]:
    episodes: list[Episode] = []

    for path in sorted(music_dir.glob("*.mp3")):
        try:
            tags, duration_seconds = probe_mp3(ffprobe_bin, path)
        except PodcastFeedError as error:
            print(f"Warning: skipping {path}: {error}", file=sys.stderr)
            continue

        artist = tags.get("artist") or tags.get("album_artist")
        album = tags.get("album")
        if not artist or not album:
            print(f"Warning: skipping untagged recording: {path}", file=sys.stderr)
            continue
        if artist.casefold() != station_name.casefold() or album.casefold() != show_name.casefold():
            continue

        enclosure_url = f"{base_url}/audio/{quote(path.name, safe='')}"
        episodes.append(
            Episode(
                path=path,
                title=tags.get("title", path.stem),
                description=tags.get("comment", f"Recorded from {station_name}."),
                published_at=datetime.fromtimestamp(path.stat().st_mtime, timezone.utc),
                duration_seconds=duration_seconds,
                enclosure_url=enclosure_url,
            )
        )

    episodes.sort(key=lambda episode: episode.published_at, reverse=True)
    return episodes


def format_duration(duration_seconds: int) -> str:
    hours, remainder = divmod(duration_seconds, 3600)
    minutes, seconds = divmod(remainder, 60)
    return f"{hours:02d}:{minutes:02d}:{seconds:02d}"


def add_text_element(
    parent: ET.Element,
    name: str,
    text: str,
    attributes: dict[str, str] | None = None,
) -> ET.Element:
    element = ET.SubElement(parent, name, attributes or {})
    element.text = text
    return element


def indent_xml(element: ET.Element, level: int = 0) -> None:
    indentation = "\n" + level * "  "
    child_indentation = "\n" + (level + 1) * "  "
    if len(element):
        if not element.text or not element.text.strip():
            element.text = child_indentation
        for child in element:
            indent_xml(child, level + 1)
        if not child.tail or not child.tail.strip():
            child.tail = indentation
    elif level and (not element.tail or not element.tail.strip()):
        element.tail = indentation


def build_feed(
    station_name: str,
    show_name: str,
    language: str,
    base_url: str,
    feed_url: str,
    episodes: list[Episode],
) -> ET.ElementTree:
    podcast_title = f"{station_name} - {show_name}"
    podcast_description = f"Recordings of {show_name} from {station_name}."

    rss = ET.Element("rss", {"version": "2.0"})
    channel = ET.SubElement(rss, "channel")
    add_text_element(channel, "title", podcast_title)
    add_text_element(channel, "link", base_url)
    add_text_element(channel, "description", podcast_description)
    add_text_element(channel, "language", language)
    add_text_element(channel, "lastBuildDate", format_datetime(datetime.now(timezone.utc), usegmt=True))
    ET.SubElement(
        channel,
        f"{{{ATOM_NAMESPACE}}}link",
        {"href": feed_url, "rel": "self", "type": "application/rss+xml"},
    )
    add_text_element(channel, f"{{{ITUNES_NAMESPACE}}}author", station_name)
    add_text_element(channel, f"{{{ITUNES_NAMESPACE}}}summary", podcast_description)
    add_text_element(channel, f"{{{ITUNES_NAMESPACE}}}explicit", "false")
    ET.SubElement(channel, f"{{{ITUNES_NAMESPACE}}}category", {"text": "Music"})

    for episode in episodes:
        item = ET.SubElement(channel, "item")
        add_text_element(item, "title", episode.title)
        add_text_element(item, "description", episode.description)
        add_text_element(item, "link", episode.enclosure_url)
        add_text_element(item, "pubDate", format_datetime(episode.published_at, usegmt=True))
        guid = hashlib.sha256(episode.enclosure_url.encode("utf-8")).hexdigest()
        add_text_element(item, "guid", f"urn:sha256:{guid}", {"isPermaLink": "false"})
        ET.SubElement(
            item,
            "enclosure",
            {
                "url": episode.enclosure_url,
                "length": str(episode.path.stat().st_size),
                "type": "audio/mpeg",
            },
        )
        add_text_element(item, f"{{{ITUNES_NAMESPACE}}}author", station_name)
        add_text_element(item, f"{{{ITUNES_NAMESPACE}}}duration", format_duration(episode.duration_seconds))
        add_text_element(item, f"{{{ITUNES_NAMESPACE}}}episodeType", "full")
        add_text_element(item, f"{{{ITUNES_NAMESPACE}}}explicit", "false")

    indent_xml(rss)
    return ET.ElementTree(rss)


def write_feed_atomically(feed: ET.ElementTree, destination: Path) -> None:
    destination.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = None

    try:
        with tempfile.NamedTemporaryFile(
            mode="wb",
            prefix=f".{destination.name}.",
            dir=destination.parent,
            delete=False,
        ) as temporary_file:
            temporary_path = Path(temporary_file.name)
            feed.write(temporary_file, encoding="utf-8", xml_declaration=True)
        temporary_path.chmod(0o644)
        os.replace(temporary_path, destination)
    finally:
        if temporary_path and temporary_path.exists():
            temporary_path.unlink()


def main() -> int:
    args = parse_args()

    try:
        base_url = normalize_base_url(args.base_url)
        music_dir = args.music_dir.expanduser().resolve()
        feed_dir = args.feed_dir.expanduser().resolve()
        if not music_dir.is_dir():
            raise PodcastFeedError(f"music directory does not exist: {music_dir}")

        ffprobe_bin = shutil.which("ffprobe")
        if not ffprobe_bin:
            raise PodcastFeedError("ffprobe was not found in PATH")

        feed_filename = f"{slugify(args.station)}-{slugify(args.show)}.xml"
        feed_url = f"{base_url}/feeds/{quote(feed_filename, safe='')}"
        episodes = collect_episodes(music_dir, base_url, args.station, args.show, ffprobe_bin)
        if not episodes:
            raise PodcastFeedError(f"no tagged MP3 recordings found for {args.station} - {args.show}")

        feed = build_feed(args.station, args.show, args.language, base_url, feed_url, episodes)
        destination = feed_dir / feed_filename
        write_feed_atomically(feed, destination)
    except PodcastFeedError as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1

    print(f"Generated podcast feed: {destination}")
    print(f"Subscription URL: {feed_url}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
