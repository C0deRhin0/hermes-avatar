#!/usr/bin/env bash
set -euo pipefail

DOMAIN="cloud-vps.tail32261a.ts.net"
CERT_DIR="${WORKSPACE_ROOT}/hermes-memory-wiki/runtime/tailscale-certs"
CERT_FILE="$CERT_DIR/$DOMAIN.crt"
KEY_FILE="$CERT_DIR/$DOMAIN.key"
MIN_VALIDITY="720h" # renew only when less than roughly 30 days remain

TMP_DIR="$(mktemp -d)"
trap 'sudo rm -rf "$TMP_DIR"' EXIT

sudo mkdir -p "$CERT_DIR"
sudo tailscale cert \
  --min-validity "$MIN_VALIDITY" \
  --cert-file "$TMP_DIR/$DOMAIN.crt" \
  --key-file "$TMP_DIR/$DOMAIN.key" \
  "$DOMAIN" >/dev/null

changed=0
if ! sudo test -f "$CERT_FILE" || ! sudo cmp -s "$TMP_DIR/$DOMAIN.crt" "$CERT_FILE"; then
  changed=1
fi
if ! sudo test -f "$KEY_FILE" || ! sudo cmp -s "$TMP_DIR/$DOMAIN.key" "$KEY_FILE"; then
  changed=1
fi

if [ "$changed" -eq 1 ]; then
  sudo install -m 0644 "$TMP_DIR/$DOMAIN.crt" "$CERT_FILE"
  sudo install -m 0600 "$TMP_DIR/$DOMAIN.key" "$KEY_FILE"
  sudo chown root:root "$CERT_FILE" "$KEY_FILE"
  sudo docker restart knowledge-base >/dev/null
  echo "Renewed Tailscale HTTPS certificate for $DOMAIN and restarted knowledge-base."
fi
