# Self-Hosted Hermes Harness Blueprint Inventory

Use this as a checklist when the operator asks for a replication blueprint of this VPS-resident Hermes setup. Keep it specifics-heavy and avoid narrative changelog style.

## Core paths

```text
${WORKSPACE_ROOT}
${WORKSPACE_ROOT}/Github/<project>/codebase
${WORKSPACE_ROOT}/Github/<project>/.opencode
${WORKSPACE_ROOT}/.opencode-master
${WORKSPACE_ROOT}/hermes-memory-wiki
${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md
${HOME}/.hermes/HERMES_USAGE_GUIDES.md
${HOME}/.hermes/SOUL.md
${HOME}/.hermes/memories/MEMORY.md
${HOME}/.hermes/memories/USER.md
${HOME}/OPERATOR_TODO.md
```

## Installed/custom components to inventory

- Custom plugins under `${HOME}/.hermes/plugins/`, especially `knowledge-base-retrieval`.
- Custom skills under `${HOME}/.hermes/skills/` that encode operator SOPs.
- Cron jobs from `cronjob(action='list')`; schedules should be rendered in PHT/+08:00.
- OpenCode wrappers:
  - `${HOME}/.local/bin/opencode`
  - `${HOME}/bin/opencode-task`
  - `${HOME}/bin/opencode-harness-install`
- Knowledge Base repository under `${WORKSPACE_ROOT}/hermes-memory-wiki`.
- Portfolio deploy checkout under `/srv/www/portfolio` when describing shared Caddy routing.

## Blueprint shape

Prefer a single operator blueprint file when asked to make this replicable:

```text
${HOME}/.hermes/HERMES_HARNESS_BLUEPRINT.md
```

Optionally mirror or summarize it into Knowledge Base as:

```text
vault/documents/hermes-harness-blueprint.md
```

Sections should be concrete:

1. Host assumptions and user/home paths.
2. Workspace and GitHub project layout.
3. Hermes profile/config/plugin/skill layout.
4. Cron automation inventory with schedules and scripts.
5. Knowledge Base architecture and rebuild pipeline.
6. Retrieval/search/index components.
7. OpenCode harness/wrapper policy.
8. Caddy/Docker/Tailscale/private routing.
9. Operator docs and changelog discipline.
10. Verification commands and smoke tests.
11. Non-goals and safety boundaries.

## Pitfalls

- Do not turn the blueprint into a chronological changelog. Use the changelog only as source evidence.
- Do not copy secrets, raw session transcripts, or retrieval DB internals into a blueprint.
- Do not assume generated Knowledge Base pages are the full canonical source when a raw operator document exists; inspect the source doc for complete history.
