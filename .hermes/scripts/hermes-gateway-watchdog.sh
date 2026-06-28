#!/usr/bin/env bash
set -euo pipefail

LOCK_FILE="${HOME}/.hermes/state/hermes-gateway-watchdog.lock"
HERMES_BIN_DEFAULT="${HOME}/.local/bin/hermes"
HERMES_BIN="${HERMES_BIN:-}"
VERBOSE="${HERMES_WATCHDOG_VERBOSE:-0}"
DRY_RUN="${HERMES_WATCHDOG_DRY_RUN:-0}"
CHECK_OUTDATED_DEFAULT="${HERMES_WATCHDOG_CHECK_OUTDATED_DEFAULT:-0}"
RESEARCHER_PROFILE="${HERMES_WATCHDOG_RESEARCHER_PROFILE:-researcher}"
RESEARCHER_USER="${HERMES_WATCHDOG_RESEARCHER_USER:-hermes}"
RESEARCHER_HOME="${HERMES_WATCHDOG_RESEARCHER_HOME:-${HOME}}"
RESEARCHER_UID="${HERMES_WATCHDOG_RESEARCHER_UID:-1000}"
SYSTEM_SERVICE="${HERMES_WATCHDOG_SYSTEM_SERVICE:-hermes-gateway.service}"
RESEARCHER_SERVICE="${HERMES_WATCHDOG_RESEARCHER_SERVICE:-hermes-gateway-researcher.service}"

if [[ -z "$HERMES_BIN" ]]; then
  if command -v hermes >/dev/null 2>&1; then
    HERMES_BIN="$(command -v hermes)"
  else
    HERMES_BIN="$HERMES_BIN_DEFAULT"
  fi
fi

if [[ ! -x "$HERMES_BIN" ]]; then
  echo "ERROR: Hermes CLI not found or not executable at $HERMES_BIN" >&2
  exit 1
fi

exec 9>"$LOCK_FILE"
if ! flock -n 9; then
  [[ "$VERBOSE" == "1" ]] && echo "Hermes gateway watchdog: another run is already in progress"
  exit 0
fi

log() {
  echo "$*"
}

run_cmd() {
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: $*"
    return 0
  fi
  "$@"
}

run_system_hermes() {
  if [[ "$(id -u)" -eq 0 ]]; then
    run_cmd "$HERMES_BIN" "$@"
  else
    run_cmd sudo -n "$HERMES_BIN" "$@"
  fi
}

run_researcher_hermes() {
  local runtime_dir="/run/user/${RESEARCHER_UID}"
  if [[ "$(id -u)" -eq 0 ]]; then
    run_cmd sudo -n -u "$RESEARCHER_USER" -H env \
      HOME="$RESEARCHER_HOME" \
      XDG_RUNTIME_DIR="$runtime_dir" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
      "$HERMES_BIN" -p "$RESEARCHER_PROFILE" "$@"
  else
    run_cmd env \
      HOME="$RESEARCHER_HOME" \
      XDG_RUNTIME_DIR="$runtime_dir" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
      "$HERMES_BIN" -p "$RESEARCHER_PROFILE" "$@"
  fi
}

get_systemd_field() {
  local scope="$1"
  local service="$2"
  local field="$3"
  if [[ "$scope" == "system" ]]; then
    systemctl show "$service" -p "$field" --value 2>/dev/null || true
  else
    local runtime_dir="/run/user/${RESEARCHER_UID}"
    sudo -n -u "$RESEARCHER_USER" -H env \
      HOME="$RESEARCHER_HOME" \
      XDG_RUNTIME_DIR="$runtime_dir" \
      DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
      systemctl --user show "$service" -p "$field" --value 2>/dev/null || true
  fi
}

service_is_running() {
  local scope="$1"
  local service="$2"
  local active sub
  active="$(get_systemd_field "$scope" "$service" ActiveState)"
  sub="$(get_systemd_field "$scope" "$service" SubState)"
  [[ "$active" == "active" && "$sub" == "running" ]]
}

check_default_outdated() {
  [[ "$CHECK_OUTDATED_DEFAULT" == "1" ]] || return 1
  local status_output
  if ! status_output="$(run_system_hermes gateway status --system 2>&1 || true)"; then
    return 1
  fi
  grep -q "Installed gateway service definition is outdated" <<<"$status_output"
}

repair_default_unit_if_needed() {
  log "Refreshing default/system gateway unit via: $HERMES_BIN gateway install --system"
  run_system_hermes gateway install --system
}

restart_default_gateway() {
  log "Restarting default/system gateway via systemctl restart ${SYSTEM_SERVICE}"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: systemctl restart ${SYSTEM_SERVICE}"
    return 0
  fi
  systemctl restart "$SYSTEM_SERVICE"
}

restart_researcher_gateway() {
  local runtime_dir="/run/user/${RESEARCHER_UID}"
  log "Restarting ${RESEARCHER_PROFILE} gateway via user systemd service ${RESEARCHER_SERVICE}"
  if [[ "$DRY_RUN" == "1" ]]; then
    log "DRY_RUN: sudo -n -u ${RESEARCHER_USER} -H env HOME=${RESEARCHER_HOME} XDG_RUNTIME_DIR=${runtime_dir} DBUS_SESSION_BUS_ADDRESS=unix:path=${runtime_dir}/bus systemctl --user restart ${RESEARCHER_SERVICE}"
    return 0
  fi
  sudo -n -u "$RESEARCHER_USER" -H env \
    HOME="$RESEARCHER_HOME" \
    XDG_RUNTIME_DIR="$runtime_dir" \
    DBUS_SESSION_BUS_ADDRESS="unix:path=${runtime_dir}/bus" \
    systemctl --user restart "$RESEARCHER_SERVICE"
}

main() {
  local did_work=0
  local default_reason=""
  local researcher_reason=""

  if ! service_is_running system "$SYSTEM_SERVICE"; then
    default_reason="system service state is $(get_systemd_field system "$SYSTEM_SERVICE" ActiveState)/$(get_systemd_field system "$SYSTEM_SERVICE" SubState)"
  elif check_default_outdated; then
    log "default: unit drift detected but service is running; skipping auto-restart"
  fi

  if ! service_is_running user "$RESEARCHER_SERVICE"; then
    researcher_reason="researcher service state is $(get_systemd_field user "$RESEARCHER_SERVICE" ActiveState)/$(get_systemd_field user "$RESEARCHER_SERVICE" SubState)"
  fi

  if [[ -n "$default_reason" ]]; then
    did_work=1
    log "Hermes gateway watchdog"
    log "default: unhealthy — $default_reason"
    if [[ "$default_reason" == *"outdated"* ]]; then
      repair_default_unit_if_needed
    fi
    restart_default_gateway
  fi

  if [[ -n "$researcher_reason" ]]; then
    if [[ "$did_work" == "0" ]]; then
      log "Hermes gateway watchdog"
    fi
    did_work=1
    log "${RESEARCHER_PROFILE}: unhealthy — $researcher_reason"
    restart_researcher_gateway
  fi

  if [[ "$did_work" == "0" && "$VERBOSE" == "1" ]]; then
    log "Hermes gateway watchdog: both default and ${RESEARCHER_PROFILE} gateways look healthy"
  fi
}

main "$@"
