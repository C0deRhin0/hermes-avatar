---
name: durable-operator-todo
title: Durable Operator TODOs and Deferred Task Queue
category: productivity
description: >
  Cross-session, session-independent persistent operator TODOs and deferred action queue logic for Hermes deployments. Sustainable tracking, surfaced in both file and wiki, always actionable, never lost on chat wipe or context expiry.
tags:
  - todo
  - operator
  - persistence
  - deferred
  - knowledge-base
---

## Trigger
Whenever an operator-level task or command should be resurfaced in future sessions (e.g. requires context, access, user intervention, or deferred input).

## Steps
1. **On first deferral or explicit operator hold:**
    - Write a new entry into `${HOME}/OPERATOR_TODO.md` (full markdown, timestamped, and structured by: status, overview, problem, actions taken, actions next, notes...)
    - Keep a repo-local helper at `${WORKSPACE_ROOT}/hermes-memory-wiki/operator-index.md`.
    - Keep the web-visible wiki note at `${WORKSPACE_ROOT}/hermes-memory-wiki/vault/documents/operator-todo-index.md` so the task appears inside the Knowledge Base graph/UI.
    - On Knowledge Base rebuilds, `scripts/generate_vault.py` regenerates both `operator-index.md` and `vault/documents/operator-todo-index.md` from `${HOME}/OPERATOR_TODO.md`.
2. **When operating in chat or assistant summaries:**
    - For all operator TODOs, reference this file directly to ensure session wipes, memory quotas, or outages do not lose TODOs.
    - Always check for `${HOME}/OPERATOR_TODO.md` at session boot for live work or `${WORKSPACE_ROOT}/hermes-memory-wiki/operator-index.md` for wiki web display.
3. **Interpretation rule for 'add it to my todo':**
    - For the operator, unqualified requests like "add that to my todo" should default to the **durable operator TODO queue**, not the ephemeral session `todo` tool, unless he explicitly says he wants a session-only/current-turn checklist item.
    - If a session todo was created by mistake for a clearly persistent/deferred task, move or copy the item into `${HOME}/OPERATOR_TODO.md` and tell him the durable queue is the canonical store.
4. **Surfacing:**
    - When the operator asks to "show my todos" or similar, present both: (a) the current session `todo` tool list and (b) the durable operator TODO queue, clearly labeled as separate stores.
    - Present a summary of open/deferred operator TODOs during briefings or on explicit user request ("show operator todo").

## Pitfalls
- Do NOT rely on 'memory' for durable TODOs—the quota is small and non-surviving after mass prune.
- Never save per-session tasks when the user is asking for something persistent/deferred; operator-level TODOs belong in `${HOME}/OPERATOR_TODO.md`.
- Do not silently treat the session `todo` tool and operator TODO file as the same system; explain the distinction when relevant.
- Reference both operator TODO file and wiki for completeness.

## Verification
- Check `${HOME}/OPERATOR_TODO.md`, `${WORKSPACE_ROOT}/hermes-memory-wiki/operator-index.md`, and `${WORKSPACE_ROOT}/hermes-memory-wiki/vault/documents/operator-todo-index.md` all reflect the latest deferred tasks.
- After changing generation/rebuild behavior, use a focused `/tmp/hermes-verify-*.sh` ad-hoc verification script instead of claiming suite-green.
- Verify the live Knowledge Base route for the generated note when wiki surfacing is part of the task.

# References
- [references/first-example-entry.md](references/first-example-entry.md)
- [references/rebuild-and-verify.md](references/rebuild-and-verify.md)
