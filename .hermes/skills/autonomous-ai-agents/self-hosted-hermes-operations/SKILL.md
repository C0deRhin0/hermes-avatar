---
name: self-hosted-hermes-operations
description: Operate a self-hosted Hermes deployment on a VPS with attention to timezone correctness, media retention, privacy boundaries, and chat UX tradeoffs.
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux]
---

# Self-Hosted Hermes Operations

Use this skill when working on a user-managed Hermes deployment on a VPS or server, especially when the task involves gateway behavior, cron schedules, media handling, storage growth, privacy questions, or chat UX toggles like `/verbose`.

This skill complements the bundled `hermes-agent` skill. Load both when working on Hermes itself. `hermes-agent` remains the source for general commands and features; this skill captures durable operational patterns for self-hosted deployments.

## When to use

Trigger this skill when the user asks about any of:

- where Hermes stores uploaded images, audio, videos, or documents
- whether media is deleted automatically or can fill disk
- whether user-uploaded assets stay local or also go to upstream providers
- authenticated browsing questions, especially whether giving Hermes a Google account enables Gmail/Docs/Drive access or full GUI-like behavior
- Google sign-in friction from a VPS browser (CAPTCHA, verification, phone requirements, session reuse strategy)
- cron jobs firing at the wrong local time on a VPS
- Hermes timezone vs server timezone mismatches
- whether `/verbose` increases cost or just changes presentation
- adding housekeeping automation for a long-running Hermes gateway
- verifying or rolling out a passive provider proxy (for example Headroom) across one or more Hermes gateway profiles
- producing a replication blueprint for the operator's VPS-resident Hermes harness
- creating or reshaping specialist Hermes profiles (for example `researcher`) while keeping one shared Knowledge Base

## Core workflow

1. **Check live config and runtime separately.**
   - Hermes timezone, tool routing, and gateway behavior may differ from host/server timezone.
   - Verify both the config and the runtime behavior before concluding the root cause.

2. **Treat media handling as a privacy + storage question, not just a feature question.**
   - Answer both:
     - where the bytes land locally
     - whether processing sends them upstream to external providers
   - Distinguish clearly between transport layer (e.g. Telegram), local VPS cache, and provider processing.

3. **Inspect cache retention before assuming cleanup exists.**
   - Hermes may auto-prune some caches but not others.
   - Confirm per cache type instead of making a blanket statement.

4. **When adding cleanup automation, prefer a quiet script-based cron job.**
   - Use `no_agent=True` and `deliver=local` unless the user explicitly wants chat notifications.
   - Make the script silent on zero-action runs and chatty only on deletion or failure.

5. **For timezone-sensitive cron work, verify the scheduled timestamps after editing.**
   - Do not stop at changing a config value.
   - Re-save or re-edit affected cron jobs so `next_run_at` is recalculated in the intended timezone.
   - On some Linux/VPS setups, `datetime.astimezone().strftime('%Z')` can misleadingly render `PST` even while the real local zone is `Asia/Manila` / `+08:00`.
   - When verifying or fixing human-readable timezone labels, check live evidence such as `/etc/localtime`, `timedatectl`, and the rendered numeric offset, not `%Z` alone.
   - Prefer explicitly normalizing human-facing Asia/Manila labels to `PHT` in operator-facing output paths when correctness matters.

6. **For `/verbose` questions, separate model-token cost from presentation-layer noise.**
   - Check whether the setting changes agent history/prompt assembly or only progress display.
   - Explain that indirect cost can still rise if verbose display causes longer human-in-the-loop sessions.

## Durable findings for this class of system

### Harness blueprint questions

When the operator asks for a blueprint to replicate this setup, do not answer from memory alone. Build a specifics-heavy inventory from live files and current cron/plugin/wrapper state, then organize it by subsystem rather than by date. Use `references/harness-blueprint-inventory.md` as the checklist. The raw operator changelog is source evidence; generated wiki summaries may intentionally tail or condense it.

### Specialist-profile bootstrap pattern

When the operator wants a specialist Hermes profile on the VPS, treat it as a state-separation design problem rather than a persona-only rename.

Core rules:
- `default` is the root profile at `~/.hermes`; do not assume `~/.hermes/profiles/default` exists.
- named profiles live under `~/.hermes/profiles/<name>/` and isolate config, env, SOUL, sessions, skills, cron state, and memory.
- keeping `default` as the broad orchestrator/main brain is a good default, but it will not automatically share cognition with child profiles.
- when the operator wants one second brain, keep a single shared Knowledge Base and separate specialist output with provenance metadata such as `source_profile: researcher` instead of forking per-profile archives by default.
- when cloning a profile that may later get its own Telegram identity, do **not** leave the parent bot token in place; require a distinct bot token per profile to avoid same-bot gateway collisions.
- when transferring a responsibility like a weekly research digest, move the cron job into the specialist profile and remove/disable the duplicate in `default`.
- always verify the specialist profile with `profile show`, profile-specific `status`, profile-specific `cron list`, and one one-shot chat that proves the specialist SOUL is active.

Reference: `references/specialist-profiles.md`.

Reference: `references/asia-manila-pht-label-normalization.md
- `references/cron-timing-vs-label-checks.md` — fast check to distinguish correct Asia/Manila scheduling from bad human-readable timezone labels, plus terse operator reply pattern for quick audits.`.

### Media handling questions

When a user asks "can you analyze images / accept voice" on a self-hosted Hermes setup, also be ready to answer:

- local cache paths
- retention behavior
- whether STT/TTS/vision routes send data upstream
- whether manual cleanup or retention controls are needed

Do not answer capability alone when the user's real concern is storage or privacy.

### Retention pitfall

**Pitfall:** assuming all media caches are auto-cleaned because image cache is pruned.

**Safer approach:** verify each cache independently. A Hermes deployment can prune image/document caches while still allowing audio/video caches to accumulate.

### Verbose-mode pitfall

**Pitfall:** treating `/verbose` as inherently "more tokens."

**Safer approach:** verify whether verbose mode is a presentation-layer tool-progress setting. If it only changes gateway/CLI progress display, describe it as mostly UI verbosity rather than prompt inflation.

### Authenticated browsing / Google-account pitfall

**Pitfall:** telling the user that handing Hermes a Google account will make browser automation equivalent to a full GUI workstation, or implying that stealth alone should solve Google login from a VPS.

**Safer approach:** frame the account as a **logged-in browser identity layer** only. Distinguish browser automation from full desktop control. When Google blocks sign-in, describe the exact verification gate reached and treat it primarily as an account-trust / trusted-device problem, not just a `navigator.webdriver` problem. Prefer trusted-device completion plus session reuse over repeated first-time login attempts from a VPS browser.

Reference notes: `references/google-authenticated-browsing.md`.

## Implementation pattern: media-cache cleanup

Preferred pattern:

- script under `~/.hermes/scripts/`
- script deletes stale media by age threshold
- cron runs daily in local delivery mode
- verify with one manual script run and one immediate cron run
- record the change in `~/.hermes/HERMES_CONFIG_CHANGELOG.md`

Reference implementation notes live in `references/hermes-media-retention-and-verbose.md`.

## Passive provider-proxy rollout pattern

When adding a passive proxy layer in front of a self-hosted Hermes provider path (for example Headroom in front of `openai-codex`), treat it as a **complementary transport-layer change**, not as a replacement for existing context tooling such as RTK or Hermes built-in compression.

Recommended sequence:

1. Verify the target provider's runtime override path, not just the static config file.
   - For `openai-codex`, confirm the runtime uses `HERMES_CODEX_BASE_URL` rather than assuming `model.base_url` alone is authoritative.
2. Canary the proxy on a separate loopback port first.
3. Verify the proxy with a direct OpenAI-compatible request before claiming Hermes is using it.
   - For Codex Responses paths, use `store=False` and `stream=True` and confirm a real streamed response body comes back.
4. Check proxy-side evidence such as `/health` and `/stats`, especially whether `/v1/responses` traffic is being recorded.
5. Only then install a durable systemd unit / gateway drop-in for global rollout.
6. In multi-profile deployments, verify each active gateway service independently.
   - A system-level drop-in for `hermes-gateway.service` does **not** automatically propagate to named-profile user services such as `hermes-gateway-researcher.service`.
   - Use `hermes gateway list` plus per-service env inspection to confirm which profiles actually inherited the override.
7. Before touching any live gateway service or systemd drop-in, do a **one-shot Hermes CLI canary** with a temporary runtime override such as `HERMES_CODEX_BASE_URL=http://127.0.0.1:<new_proxy_port>/v1` and a trivial prompt. This proves the full `Hermes -> new proxy -> existing proxy/provider` chain works while keeping the production gateway untouched.
8. In multi-profile deployments, prefer a **researcher/specialist-profile live canary first** and keep the default/system gateway prepared-only until the canary is accepted. A practical pattern is:
   - install and verify the new loopback service first;
   - stage the default/system drop-in as a non-active `*.prepared` file;
   - enable the real `.conf` only for the specialist-profile user service;
   - verify that the default/system gateway still points at the old loopback provider while the specialist profile points at the new one.
9. After rollout, verify the live gateway process environment (for example via `/proc/<pid>/environ`) to confirm the override is actually loaded for the intended service(s).
10. For privacy/policy gateways in front of Headroom, require **transport evidence** in addition to unit tests:
   - local health endpoint returns success;
   - a direct smoke request through the new proxy reaches the proxy and can report redaction findings, even if the downstream returns `401` because auth was intentionally omitted;
   - compare a benign prompt and a PII-bearing prompt directly against the proxy and confirm findings stay low/zero for benign input while increasing for real sensitive input;
   - a one-shot Hermes CLI canary returns the expected text;
   - Headroom `/stats` still shows `/v1/responses` traffic after the canary.
11. Before broadening a privacy-gateway rollout from a specialist profile to the default profile, run a **side-by-side baseline comparison**:
   - use the default profile's current direct path as the control and the specialist-profile/privacy-gateway path as the experiment;
   - cover at least: a general prompt, a technical/debugging prompt, a coding prompt, a benign prompt that includes incidental PII, a technical prompt with PII context, and one longer open-ended prompt;
   - include at least one exact-output control prompt on both paths to check that routing/redaction did not break instruction following;
   - inspect outputs for semantic degradation, malformed formatting, unexpected omissions, and leakage of the prompt's private values.
12. After any privacy-gateway code change, restart the live gateway service before judging canary behavior.
   - Repo tests passing is not enough if the installed `privacy-gateway.service` is still running the old process.
   - Re-run one benign direct probe and one sensitive direct probe after the restart to confirm the live findings headers reflect the new logic.
13. Treat partially masked secret fragments as sensitive too.
   - Support-log style values such as `ghp_abcd1234...wxyz9876` should be redacted even when they are not full tokens, because they are still useful for correlation or secret reconstruction.

Reference: `references/privacy-gateway-side-by-side-verification.md`.
11. Before broadening a privacy-gateway rollout, run **adversarial false-positive / over-reduction probes** on benign structured text such as semantic versions, datetimes, room/build numbers, and invalid IP-like strings.
12. For privacy-gateway canaries, compare **exact-output parity** between the default direct-to-Headroom path and the canary profile on prompts that demand exact literals or exact JSON. This catches redaction logic that silently degrades model output.
13. After changing privacy-gateway code, restart the installed systemd service before interpreting live canary results. A passing test suite proves the code on disk, not the already-running process.
14. Keep a concise operator reference for this class of rollout in `references/privacy-gateway-edge-case-verification.md`.

### Isolation-first proxy implementation pattern

When introducing a new privacy / policy / compatibility layer in front of an existing working provider proxy, keep the change removable:
- put the new logic in its own repo/service;
- avoid Hermes source edits unless a verified protocol incompatibility forces it;
- avoid Headroom/source-proxy edits unless unavoidable;
- use temporary env overrides for end-to-end validation first;
- defer systemd cutover until unit tests, local health checks, and a one-shot Hermes canary all pass.

This keeps rollback simple: stop the new service and restore Hermes directly to the prior loopback base URL.

### Gateway restart pitfall

**Pitfall:** trying to restart the Hermes gateway from inside the active gateway turn.

**Safer approach:** use a separate shell or a detached `systemd-run` helper so the restart is not killed by the gateway's own shutdown path.

**Additional operator note:** for the default/system gateway, detached restarts are the reliable path when working from inside Telegram/gateway context. A temporary one-shot cron or helper script may still emit a misleading generic failure notification if the wrapper times out, even when the underlying rollout later succeeds. When that happens, inspect the cron output artifact for the real failure mode (for example `script timed out after 120s`) and verify the live service state separately before concluding the rollout failed.

### VPS watchdog pattern for multi-profile gateways

When the operator wants the VPS itself to keep Hermes gateways healthy, prefer a **machine-side systemd timer + watchdog script** over a blind recurring cron restart.

Recommended shape:
- a root-owned oneshot service + timer (for example every 30 minutes) calls a quiet-by-default watchdog script;
- the watchdog checks the default/system gateway and each named-profile user gateway independently;
- healthy runs stay silent; only action/failure emits output;
- use a non-blocking lock file under a durable writable path (for example `~/.hermes/state/...`), not `/tmp`.

Recommended health checks:
- default/system gateway unhealthy when `hermes-gateway.service` is not `active/running`;
- if Hermes reports `Installed gateway service definition is outdated` while the service is still running, treat that as a maintenance item rather than a trigger for an automatic live-session restart;
- named-profile/user gateways unhealthy when their user services are not `active/running`, checked against the correct user systemd bus.

Recommended recovery path on this class of host:
- **default/system gateway:**
  1. for an actual outage, restart the service with `systemctl restart hermes-gateway.service`;
  2. for unit drift while the service is healthy, prefer a maintenance-safe unit refresh (write the freshly generated unit and `systemctl daemon-reload`) instead of bouncing the live gateway.
- **named-profile/user gateway (e.g. researcher):**
  - restart the user unit via `systemctl --user restart hermes-gateway-<profile>.service` under the target user context with explicit `HOME`, `XDG_RUNTIME_DIR`, and `DBUS_SESSION_BUS_ADDRESS`.

Why this pattern:
- it avoids relying on root cron PATH for a bare `hermes` binary;
- it separates `unit refresh` from `service restart` for the default gateway;
- it avoids assuming `--system` covers named-profile user services;
- it is more robust than a blind periodic restart because it only acts when unhealthy;
- it avoids interrupting active chats solely to repair a harmless service-file PATH mismatch.
Reference note: `references/gateway-watchdog-systemd.md`.

### Codex proxy verification pitfall

**Pitfall:** treating a successful one-shot CLI reply as sufficient proof that the passive proxy is in use.

**Safer approach:** require transport-level evidence too:
- proxy `/stats` shows `/v1/responses` traffic
- direct streamed request through the proxy succeeds
- live gateway process environment contains the intended runtime override
- when multiple profiles are active, verify the override per gateway service instead of assuming the default profile's system service covers named-profile user services

Reference notes: `references/passive-provider-proxy-rollout.md`.

Reference: `references/privacy-gateway-rollout.md`.

### Multi-profile gateway proxy pitfall

**Pitfall:** assuming a proxy rollout to the default/system gateway also covers specialist profiles.

**Safer approach:** check `hermes gateway list`, inspect both the system service and any user-profile services, and compare their loaded env. A healthy proxy plus a correct default gateway override can still leave `researcher` or other named profiles bypassing the proxy entirely.

## Dashboard reverse-proxy WebSocket pitfall

**Pitfall:** seeing the dashboard page load successfully and concluding the Hermes dashboard itself is healthy, while embedded chat still fails with reconnect loops, `websocket connection failed`, or `events feed disconnected — tool calls may not appear`.

**Safer approach:** treat dashboard HTML success and chat-WebSocket success as separate checks. Inspect Hermes logs for WebSocket rejection reasons such as:
- `origin_mismatch`
- `host_mismatch`
- `auth rejected`

In reverse-proxy deployments where the public hostname differs from the upstream bind authority (for example public `dashboard.example.com` proxied to `100.x.x.x:9119`), verify whether the proxy is rewriting `Host` without also making the WebSocket `Origin` consistent. If logs show `pty refused: origin_mismatch origin=https://<public-host> bound=<upstream-bind-host>`, the fix may be a proxy header adjustment rather than a dashboard restart.

Reference: `references/dashboard-reverse-proxy-websocket-troubleshooting.md`.

## Verification checklist

- Confirm actual cache directories on this install.
- Confirm which cache types have built-in cleanup and which do not.
- Check current disk usage before and after changes.
- Verify cron `next_run_at` is in the user-intended timezone, not server-local time.
- If changing automation/config, update the changelog.
- If answering cost questions, ground the answer in source/docs rather than intuition.
- For passive provider-proxy changes, verify both direct proxy traffic and the live gateway runtime env before calling rollout complete.
- For dashboard reverse-proxy issues, verify both page load and chat WebSocket behavior; read logs for `origin_mismatch`/`host_mismatch` before changing the dashboard process.
- When you changed scripts/config/docs but there is no obvious canonical test suite for the touched behavior, create a focused temporary verifier under `/tmp` using an OS-safe tempfile path with a `hermes-verify-` prefix, run it against the exact changed behavior, and clean it up when possible.
- Report that fallback explicitly as **ad-hoc verification**, not as a full suite green.

## Ad-hoc verifier fallback pattern

Use this when Hermes/operator changes touch wrappers, cron scripts, timezone behavior, generated artifacts, or host metadata and no canonical repo test command cleanly covers the change.

Recommended pattern:
- create a short Python verifier in `/tmp` with `tempfile.mkstemp(prefix='hermes-verify-', ...)`
- have it check the exact changed paths/behaviors only
- include both source-shape checks (for example, a required config string or wrapper import path) and runtime checks (for example, syntax/compile, command exit code, rendered cron state, generated artifact text)
- print pass/fail lines plus a final summary count
- delete the temp file afterward when possible
- in the final user report, call it `ad-hoc verification` and cite the key runtime evidence rather than implying a project-level test suite passed

## Response style for this class of task

- Be concise and practical.
- Lead with the direct answer.
- Then give the exact path, schedule, or provider implication.
- When the user is worried about privacy or disk growth, do not stop at a theoretical explanation; propose and verify a concrete safeguard.
