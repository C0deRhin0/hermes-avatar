# Dashboard reverse-proxy websocket troubleshooting

Use this note when a self-hosted Hermes Dashboard loads at a reverse-proxied hostname but embedded chat fails with websocket errors.

## Symptom cluster

Typical browser/UI symptoms:
- `websocket connection failed`
- `events feed disconnected — tool calls may not appear`
- reconnect loop after pressing `Reconnect`
- dashboard chrome loads, but chat never becomes usable

Typical Hermes log clue:

```text
pty refused: origin_mismatch origin=https://<public-host> bound=<upstream-bind-host> peer=<peer>
```

## What this usually means

The dashboard backend is reachable and serving HTML, but Hermes rejects the chat websocket because the websocket `Origin` or `Host` does not match the backend bind authority it expects.

This is most common when:
- public hostname: `dashboard.example.com`
- upstream bind: `100.x.y.z:9119` or another concrete LAN/Tailscale IP
- proxy rewrites upstream `Host`, but leaves the browser-originated `Origin` inconsistent with the upstream bind authority

## Fast workflow

1. Verify the dashboard service bind host/port from the live service definition.
2. Read Hermes logs before restarting anything.
3. If logs show `origin_mismatch` or `host_mismatch`, inspect the reverse-proxy header rewrites.
4. Treat dashboard HTML success and chat websocket success as separate checks.
5. Validate the proxy config, reload/restart the proxy, then re-test.

## Known-good fix shape for IP-bound upstreams

If the backend is bound to `100.71.144.29:9119` and the public hostname is `dashboard.example.invalid`, a working Caddy reverse-proxy block is:

```caddy
reverse_proxy http://100.71.144.29:9119 {
    header_up Host 100.71.144.29:9119
    header_up Origin https://100.71.144.29:9119
    header_up X-Forwarded-Host {host}
    header_up X-Forwarded-Proto {scheme}
}
```

Key idea:
- rewriting `Host` alone may be insufficient
- websocket `Origin` may also need to match the upstream bind authority Hermes is validating against

## Verification targets

Ad-hoc verification is usually enough for this class of fix:
- validate proxy config
- confirm the live mounted config includes the `Origin` rewrite
- HTTPS smoke-check the dashboard route still returns `200`
- re-check Hermes logs for disappearance of fresh `origin_mismatch` messages after the user retries chat

## Non-goals / pitfalls

Do **not** assume a dashboard restart is the first fix.
Do **not** conclude the issue is solved just because `/` returns HTML.
Do **not** capture this as 'browser tools don't work' or another negative self-constraint; this is a proxy/header consistency issue.
