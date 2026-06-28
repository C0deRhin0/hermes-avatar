#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="${HOME}/backups"
KEEP_BACKUPS="${HERMES_BACKUP_KEEP_COUNT:-7}"
WORKSPACE_TMP_DIR="${WORKSPACE_ROOT}/tmp"

report_lines=()
changes=0

append_report() {
  report_lines+=("$1")
}

prune_backups() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    return 0
  fi

  mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'hermes-backup-*.tar.gz' | sort)
  local count=${#backups[@]}
  if (( count <= KEEP_BACKUPS )); then
    return 0
  fi

  local prune_count=$((count - KEEP_BACKUPS))
  local removed=0
  local removed_bytes=0
  local i path size base
  for ((i=0; i<prune_count; i++)); do
    path="${backups[$i]}"
    size=$(stat -c '%s' "$path" 2>/dev/null || echo 0)
    base=$(basename "$path")
    rm -f -- "$path"
    removed=$((removed + 1))
    removed_bytes=$((removed_bytes + size))
    append_report "backups: removed ${base} (${size} bytes)"
  done

  if (( removed > 0 )); then
    changes=1
    append_report "backups: pruned ${removed} archive(s); reclaimed ${removed_bytes} bytes"
  fi
}

remove_workspace_tmp() {
  if [[ ! -d "$WORKSPACE_TMP_DIR" ]]; then
    return 0
  fi

  shopt -s nullglob dotglob
  local entries=("$WORKSPACE_TMP_DIR"/*)
  shopt -u nullglob dotglob
  if (( ${#entries[@]} == 0 )); then
    return 0
  fi

  local before size path base removed=0
  before=$(du -sb "$WORKSPACE_TMP_DIR" 2>/dev/null | awk '{print $1}')
  for path in "${entries[@]}"; do
    base=$(basename "$path")
    rm -rf --one-file-system -- "$path"
    removed=$((removed + 1))
    append_report "workspace tmp: removed ${base}"
  done
  size=$(du -sb "$WORKSPACE_TMP_DIR" 2>/dev/null | awk '{print $1}')
  changes=1
  append_report "workspace tmp: removed ${removed} item(s); reclaimed $((before - size)) bytes"
}

clear_path_if_present() {
  local label="$1"
  local path="$2"
  if [[ ! -e "$path" ]]; then
    return 0
  fi
  local before
  before=$(du -sb "$path" 2>/dev/null | awk '{print $1}')
  rm -rf --one-file-system -- "$path"
  changes=1
  append_report "${label}: removed ${path} (${before} bytes)"
}

prune_backups
remove_workspace_tmp
clear_path_if_present "cache" "${HOME}/.cache/uv/archive-v0"
clear_path_if_present "cache" "${HOME}/.cache/puccinialin"
clear_path_if_present "cache" "${HOME}/.npm"

if (( changes == 1 )); then
  echo "Weekly housekeeping"
  printf '%s
' "${report_lines[@]}"
fi
