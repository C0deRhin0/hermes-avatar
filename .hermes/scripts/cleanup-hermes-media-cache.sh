#!/usr/bin/env bash
set -euo pipefail

AUDIO_DIR="${HOME}/.hermes/audio_cache"
VIDEO_DIR="${HOME}/.hermes/cache/videos"
AUDIO_DAYS="${HERMES_AUDIO_CACHE_DAYS:-7}"
VIDEO_DAYS="${HERMES_VIDEO_CACHE_DAYS:-3}"
VERBOSE="${HERMES_CLEANUP_VERBOSE:-0}"

cleanup_dir() {
  local dir="$1"
  local days="$2"
  if [[ ! -d "$dir" ]]; then
    printf '0'
    return 0
  fi

  local deleted=0
  while IFS= read -r _file; do
    deleted=$((deleted + 1))
  done < <(find "$dir" -type f -mtime "+$days" -print -delete 2>/dev/null)

  printf '%s' "$deleted"
}

audio_deleted=$(cleanup_dir "$AUDIO_DIR" "$AUDIO_DAYS")
video_deleted=$(cleanup_dir "$VIDEO_DIR" "$VIDEO_DAYS")

if [[ "$VERBOSE" == "1" || "$audio_deleted" != "0" || "$video_deleted" != "0" ]]; then
  echo "Hermes media cache cleanup"
  echo "audio_cache: deleted ${audio_deleted} file(s) older than ${AUDIO_DAYS} day(s) from ${AUDIO_DIR}"
  echo "video_cache: deleted ${video_deleted} file(s) older than ${VIDEO_DAYS} day(s) from ${VIDEO_DIR}"
fi
