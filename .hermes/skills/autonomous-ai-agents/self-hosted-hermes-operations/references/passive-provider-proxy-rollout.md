# Passive provider-proxy rollout notes

Session-derived operator notes for adding a loopback passive proxy in front of Hermes provider traffic.

## When this reference matters
- Rolling out Headroom or a similar proxy in front of `openai-codex`
- Verifying that Hermes is truly traversing the proxy rather than only succeeding at the application layer
- Restarting the gateway safely after provider-routing changes

## Durable lessons

### 1) Runtime override beats static intuition
For `openai-codex`, validate the runtime credential path and override variable first. The durable check from this session was that the runtime credentials resolver honors:

- `HERMES_CODEX_BASE_URL`

So a passive proxy rollout should verify the loaded runtime env, not just `config.yaml`.

### 2) Canary on another loopback port first
Use a temporary local port for canary verification before switching the global gateway. This makes it easy to prove:
- the proxy boots
- `/health` is ready
- direct Responses requests succeed
- `/stats` records `/v1/responses`

### 3) Direct Responses verification needs Codex-compatible parameters
For direct OpenAI-compatible validation against the proxy, use a streamed Responses call with:
- `store=False`
- `stream=True`

This session found that non-streamed / default-shaped attempts were not the strongest validation path, while a streamed direct request returning the expected exact output and incrementing proxy stats was decisive.

### 4) Do not trust app-level success alone
A one-shot Hermes CLI success is weaker than transport evidence. Stronger proof requires all of:
- direct proxy request succeeds
- proxy `/stats` shows `/v1/responses`
- live gateway process env contains the intended override

Also: a one-shot CLI run with an env override can be ambiguous if proxy stats do not move. Treat per-service runtime env on the actual gateway process as stronger evidence than an isolated CLI success.

### 5) Multi-profile services must be verified separately
In a mixed deployment, the default gateway may run as a system service while specialist profiles run as user services. A system drop-in like:
- `/etc/systemd/system/hermes-gateway.service.d/headroom-proxy.conf`

can leave a named-profile service such as:
- `~/.config/systemd/user/hermes-gateway-researcher.service`

without the same `HERMES_CODEX_BASE_URL` override.

Durable verification pattern:
- run `hermes gateway list`
- inspect the live env for each gateway PID
- do not assume the default profile's proxy wiring covers `researcher` or other named profiles

### 6) Restart gateway from outside the gateway turn
Restarting the active gateway from inside the same gateway turn is not the safe path. Use:
- a separate shell, or
- a detached `systemd-run` helper

That avoids the restart command being torn down by the gateway's own shutdown.

## Suggested verification bundle
1. `curl /health`
2. direct streamed Responses request through proxy
3. `curl /stats`
4. inspect `/proc/<gateway-pid>/environ` for the provider base-url override
5. when multiple profiles are active, repeat env inspection for each gateway PID from `hermes gateway list`
6. confirm the relevant systemd services are active

## Scope note
These notes are about **passive transport-layer complementarity**. Do not frame this class of change as replacing RTK or Hermes built-in compression when the user explicitly wants layering.