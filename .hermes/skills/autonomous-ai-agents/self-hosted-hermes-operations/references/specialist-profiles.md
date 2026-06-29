# Specialist Hermes profiles on a self-hosted VPS

Use this note when creating a specialist profile such as `researcher` while keeping `default` as the main operator/orchestrator profile.

## Durable profile model

- The root `default` profile lives at `~/.hermes`.
- Named profiles live at `~/.hermes/profiles/<name>/`.
- Do not assume there is a `~/.hermes/profiles/default` directory.
- Each named profile gets its own config, env, SOUL, sessions, skills, cron state, and memory.
- Profile isolation is real state separation, not shared cognition.

## Recommended pattern for the operator-style specialist profiles

Use a specialist profile when the workflow benefits from separate:
- memories
- sessions
- cron jobs
- gateway identity
- skill tuning / SOUL emphasis

Good examples:
- `researcher` for web-heavy research, recurring source digestion, and long-form note production
- future coding-focused profiles with their own cron/jobs/tool defaults

Keep `default` as the broad operator/orchestrator unless the operator explicitly wants a different main brain.

## Shared Knowledge Base policy

When the goal is one second brain with multiple specialist agents:
- keep one shared Knowledge Base root
- do not fork per-profile wikis by default
- file outputs into the existing shared archive structure
- distinguish authorship with provenance metadata when practical, e.g. `source_profile: researcher`

Prefer provenance-based separation over per-profile archive trees unless the operator explicitly asks for separate archives.

## Telegram / gateway identity rule

If a specialist profile should have its own Telegram bot:
- use a distinct bot token per profile
- do not reuse the default profile's bot token across multiple profiles
- treat the separate bot as a gateway identity split, not a separate knowledge base by default

If a distinct token is not yet available, clear the cloned token from the new profile rather than risking a same-bot multi-profile collision.

## Cron migration rule

When moving a recurring responsibility into a specialist profile:
- migrate the cron job into that profile's cron store
- remove or disable the duplicate from the default profile
- verify the rendered next run in `Asia/Manila` / PHT
- when the output is meant for shared Knowledge Base storage, keep the shared-wiki path but add profile provenance in the prompt when practical

## Verification pattern

For profile bootstrap/change work, verify with concrete evidence such as:
- `hermes profile show <name>`
- `hermes -p <name> status`
- `hermes -p <name> cron list`
- one one-shot chat proving the specialist SOUL is active

If the work mainly changes docs/specs around the profile policy, run a focused temporary `/tmp/hermes-verify-*.py` script and report it as ad-hoc verification, not suite green.
