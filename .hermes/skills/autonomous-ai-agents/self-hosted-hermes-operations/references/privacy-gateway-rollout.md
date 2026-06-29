# Privacy-gateway rollout in front of Headroom

Session-derived reference for future self-hosted Hermes proxy/privacy deployments.

## Proven rollout shape

```text
Hermes -> privacy-gateway -> Headroom -> upstream provider
```

## Durable rollout pattern

1. Keep privacy logic in a standalone repo/service.
2. Do not modify Hermes or Headroom source unless a verified protocol break forces it.
3. Install the new proxy on loopback first.
4. Verify with local tests and a one-shot Hermes CLI override before any durable gateway cutover.
5. In multi-profile deployments:
   - make the specialist profile the first live canary;
   - keep the default/system gateway prepared-only until the canary is accepted.

## Verification signals that mattered

- `pytest` green for request rewriting + streaming passthrough
- direct proxy health check (`/health`)
- direct smoke request through the proxy
- one-shot Hermes CLI canary with temporary `HERMES_CODEX_BASE_URL`
- Headroom `/stats` still showing `/v1/responses` traffic
- `/proc/<pid>/environ` proving the intended gateway service actually loaded the new base URL

## Useful nuance

A direct smoke request that returns downstream `401` can still be useful evidence when:
- the request hit the new proxy;
- the proxy reports redaction findings;
- the failure is clearly downstream auth, not local proxy failure.

## Staging pattern

- active systemd service: `privacy-gateway.service`
- active specialist canary drop-in: real `.conf`
- prepared default drop-in: `*.prepared`

This makes the difference between "prepared" and "live" obvious on disk and simplifies rollback.

## Restart pitfall

Restarting a Hermes gateway from inside the active gateway turn can be killed by the gateway shutdown path. Use a truly separate shell/session/process to restart the gateway, then verify the new PID and loaded environment.
