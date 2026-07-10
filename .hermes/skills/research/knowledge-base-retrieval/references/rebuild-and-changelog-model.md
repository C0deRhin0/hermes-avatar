# Knowledge Base Rebuild + Changelog Model

Session-derived operating notes for future Knowledge Base work.

## Rebuild paths

Manual full rebuild from `${WORKSPACE_ROOT}/hermes-memory-wiki`:

```bash
./scripts/rebuild_knowledge_base.sh
```

Expanded sequence:

```bash
python3 scripts/generate_vault.py
python3 scripts/build_graph.py
python3 scripts/build_agent_index.py
python3 scripts/build_search_index.py --with-embeddings
python3 scripts/lint_wiki.py --write-report --fail-on critical
python3 scripts/build_knowledge_base.py
python3 scripts/setup_runtime.py
docker compose up -d --force-recreate
```

Cron-safe watcher wrapper:

```text
${HOME}/.hermes/scripts/knowledge-base-rebuild-on-change.py
```

Project implementation:

```text
${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/rebuild_on_change.py
```

Known active schedule at time of discovery: `every 30m`, `no_agent=True`, `deliver=local`, workdir `${WORKSPACE_ROOT}/hermes-memory-wiki`.

## Ideal rebuild architecture

Prefer two conceptual rebuild classes when evolving the watcher:

| Class | Trigger | Action |
|---|---|---|
| Content/index rebuild | memory, changelog, usage guide, SOUL, operator TODO, state DB, cron output, vault query/research pages | regenerate vault, graph, agent index, search DB, lint report, static site |
| Runtime/deployment rebuild | Caddyfile, Docker Compose, runtime config/certs, routing/security files | content rebuild plus `setup_runtime.py` and `docker compose up -d` |

Rationale: most changes only need `dist/` and `site-data/` refreshed; Docker recreation is safe but heavier than necessary for content-only changes.

## Changelog source-of-truth model

Do not confuse these two layers:

| Layer | Role |
|---|---|
| `${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md` | canonical append-style source changelog/full audit trail |
| `vault/decisions/hermes-config-changelog.md` | generated compact graph context, currently recent-summary shaped |

At the time of discovery, `scripts/generate_vault.py` summarized changelog entries with `entries[-24:]`. Treat the generated vault page as a retrieval-friendly recent decision surface, not the full audit history. Read the source changelog when full historical completeness matters.

## Good future enhancement

If the changelog grows too long for a single useful graph page, use layered archive pages:

```text
vault/decisions/hermes-config-changelog.md       # latest summary
vault/decisions/changelog-archive-YYYY-MM.md     # monthly archive summaries
vault/decisions/changelog-index.md               # links all archive pages
```

Keep raw/full detail in the source changelog and concise graph context in vault pages.
