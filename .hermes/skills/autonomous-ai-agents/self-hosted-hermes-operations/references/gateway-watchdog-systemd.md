# Gateway watchdog via systemd timer

Use this note when the operator wants the VPS itself to keep Hermes gateways healthy without blind periodic restarts.

## Preferred schedule

- Default cadence: every 15 minutes.
- Reason: fast enough to recover a dead gateway without heavy polling or noisy restarts.
- Example timer stanza:

```ini
[Timer]
OnCalendar=*:0/15
Persistent=true
RandomizedDelaySec=45
Unit=hermes-gateway-watchdog.service
```

## Preferred unit shape

```ini
[Unit]
Description=Hermes Gateway Conditional VPS Watchdog
After=network-online.target headroom-proxy.service
Wants=network-online.target

[Service]
Type=oneshot
User=root
Environment="PATH=${HOME}/.local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
ExecStart=${HOME}/.hermes/scripts/hermes-gateway-watchdog.sh
```

Key detail: set an explicit PATH for the root/systemd context so the watchdog does not depend on whichever PATH root inherited.

## Health-check logic

### Default/system gateway

Treat as unhealthy when either is true:
- `hermes-gateway.service` is not `active/running`
- `$(command -v hermes) gateway status --system` contains:
  - `Installed gateway service definition is outdated`

### Researcher / named-profile user gateway

Treat as unhealthy when the user service is not `active/running`, but query it through the correct user systemd bus, for example:

```bash
sudo -n -u hermes -H env \
  HOME=${HOME} \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user show hermes-gateway-researcher.service -p ActiveState --value
```

## Recovery pattern

### Default/system gateway

Do not rely on `sudo hermes gateway restart --system` if the host proves sensitive to root PATH or wrapper differences.

Preferred sequence:
1. refresh unit if stale:

```bash
sudo $(command -v hermes) gateway install --system
```

2. restart via systemd directly:

```bash
sudo systemctl restart hermes-gateway.service
```

This separates unit refresh from process restart and avoids needing the gateway CLI restart path in the watchdog itself.

### Researcher / named-profile user gateway

Restart the user service through the target user's bus:

```bash
sudo -n -u hermes -H env \
  HOME=${HOME} \
  XDG_RUNTIME_DIR=/run/user/1000 \
  DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
  systemctl --user restart hermes-gateway-researcher.service
```

## Locking

Use a durable writable lock file, for example:

```text
${HOME}/.hermes/state/hermes-gateway-watchdog.lock
```

Do not use `/tmp/...` blindly; a timer/service context can hit ownership or policy surprises there.

## Verification checklist

- `bash -n` passes on the watchdog script.
- Dry-run mode shows the exact default + researcher recovery commands.
- `systemd-analyze verify` passes on the service/timer definitions before install.
- `systemctl status <timer>` shows `active (waiting)` with the expected next-run time.
- If a first scheduled tick fails, inspect `journalctl -u hermes-gateway-watchdog.service` before assuming the watchdog logic is wrong; timer-context PATH and lock-file location are common culprits.

## Pitfalls

- Do not implement this as a blind periodic restart if the operator asked for conditional recovery.
- Do not assume the default/system gateway restart path also covers named-profile user gateways.
- Do not query user services from root without exporting the target user's runtime bus variables.
- Do not rely on a bare `hermes` in root/systemd contexts when an absolute path is already known to work.
