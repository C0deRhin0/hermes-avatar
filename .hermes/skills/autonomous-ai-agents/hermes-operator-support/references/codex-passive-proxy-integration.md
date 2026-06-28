# Codex passive proxy integration notes

Use this reference when evaluating a passive transport-layer proxy/compression system for a self-hosted Hermes deployment that currently runs through the OpenAI Codex OAuth provider.

## What changed in the reviewed session

A repository review of Headroom found that the broad guidance "just change the API URL" was too generic for Hermes deployments using the `openai-codex` provider.

## Durable operator lesson

For Hermes + `openai-codex`, routing is not merely a generic OpenAI-compatible `base_url` question.

Key runtime facts that matter:
- Hermes may persist `model.base_url`, but the actual Codex runtime path is resolved through provider-specific auth/runtime logic.
- In Hermes source, the Codex default runtime base URL is `https://chatgpt.com/backend-api/codex`.
- `resolve_codex_runtime_credentials()` returns runtime credentials/base URL and honors `HERMES_CODEX_BASE_URL`.
- Runtime resolution sets the provider path to Codex-style responses semantics rather than plain chat-completions semantics.

## Practical interpretation

When proposing a passive proxy canary for a Codex-backed Hermes deployment:
1. Confirm the live provider is `openai-codex`.
2. Confirm the runtime/backend shape is the ChatGPT/Codex backend family.
3. Do not assume changing `model.base_url` alone is sufficient.
4. Prefer a reversible provider-specific runtime override such as `HERMES_CODEX_BASE_URL` when testing a local proxy.
5. Preserve the expected Codex route family (`/backend-api/codex` or equivalent Codex alias support) instead of forcing a plain `/v1` story unless the proxy explicitly supports the required translation.

## Good answer shape

For operator-facing answers, structure the conclusion as:
- **Conceptually applicable:** can this proxy work passively at all?
- **Runtime-path applicable:** does it fit Hermes' current provider/auth mode?
- **Safest canary:** what is the smallest reversible change?
- **Known risk:** what part of the generic vendor guide is oversimplified?

## Headroom-specific notes from the reviewed repo

Verified during review:
- The proxy/server starts and serves health endpoints locally.
- Targeted tests around Codex aliases, output shaping, and system-prompt immutability passed.
- The implementation explicitly includes Codex route handling rather than only generic OpenAI chat-completions support.

This makes Headroom a plausible passive layer for Hermes, but only when the operator respects the Codex-specific runtime seam instead of treating it as a plain `OPENAI_BASE_URL` swap.

## What to avoid saving as a rule

Do **not** save temporary install hiccups or one-off dependency misses as durable knowledge. The durable lesson is the integration seam:
- verify runtime-provider resolution
- verify route-family compatibility
- canary with provider-specific override first
