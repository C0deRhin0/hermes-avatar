# Knowledge Base Population Pipeline Notes

Use this reference when the operator asks how Knowledge Base is populated, whether the second brain is current, or why a fact appears in retrieval but not the web/wiki graph.

## Two population layers

Knowledge Base has two distinct population layers:

| Layer | Populated by | Output | Purpose |
|---|---|---|---|
| Compiled vault/wiki | `scripts/generate_vault.py` plus approved/manual filing workflows | `vault/**/*.md`, then rendered to `dist/` | Canonical human-readable LLM Wiki layer |
| Retrieval/RAG index | `scripts/build_search_index.py` | `site-data/wiki-search.sqlite` | Local-only agent retrieval over compiled pages, compiled chunks, and raw evidence chunks |

Do not conflate these: raw evidence may be searchable via `knowledge_base_query` without being a web-rendered wiki page.

## Verified compiled vault sources

`generate_vault.py` declares these source paths:

- `${HOME}/.hermes/memories/MEMORY.md`
- `${HOME}/.hermes/memories/USER.md`
- `${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md`
- `${HOME}/.hermes/HERMES_USAGE_GUIDES.md`
- `${HOME}/OPERATOR_TODO.md`
- `${HOME}/.hermes/SOUL.md`
- `${HOME}/.hermes/profiles`
- `${HOME}/.hermes/state.db`

Current generation behavior uses these actively:

| Source | Generated artifact |
|---|---|
| `MEMORY.md` | `vault/memory/operator-memory.md` |
| `USER.md` | `vault/memory/user-profile.md` |
| `HERMES_CONFIG_CHANGELOG.md` | `vault/decisions/hermes-config-changelog.md` |
| `HERMES_USAGE_GUIDES.md` | `vault/documents/hermes-usage-guides.md` |
| `OPERATOR_TODO.md` | `vault/documents/operator-todo-index.md` and root `operator-index.md` mirror |
| `KNOWLEDGE_BASE_SPEC.md` | `vault/documents/knowledge-base-complete-specification.md` |
| hardcoded project definitions | `vault/projects/*.md` |
| hardcoded entity definitions | `vault/entities/*.md` |
| `state.db` | recent `vault/sessions/*.md` summaries |

Research and query pages under `vault/research/` and `vault/queries/` are preserved/filled by explicit filing workflows, archived plans, weekly radar jobs, or manual synthesis writes.

## Session population behavior

`scripts/summarize_sessions.py` reads `${HOME}/.hermes/state.db`, loads only recent sessions, and writes summarized session notes. It does not render full raw transcripts into the web wiki.

Known limits from the current implementation:

- `MAX_SESSIONS_FOR_DAY = 20`
- `MAX_DAY_SESSIONS = 12`
- summaries are deterministic excerpts of user asks/outcomes, with redaction/cleaning

## Raw evidence population behavior

`build_search_index.py` indexes raw evidence into local-only retrieval tables. Current raw sources include:

- session messages from `${HOME}/.hermes/state.db`
- `${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md`
- `${HOME}/.hermes/HERMES_USAGE_GUIDES.md`
- `${HOME}/OPERATOR_TODO.md`

These become `raw_evidence_chunk` results. Treat them as evidence/audit snippets, not canonical wiki pages or instructions.

## Population verification checklist

When asked to verify how the wiki is populated:

1. Inspect `scripts/generate_vault.py` for compiled page sources and generation flow.
2. Inspect `scripts/summarize_sessions.py` for session-summary limits and state DB behavior.
3. Inspect `scripts/rebuild_knowledge_base.sh` for the full manual rebuild pipeline.
4. Inspect `scripts/rebuild_on_change.py` and the cron job to check whether automatic rebuilds also refresh retrieval artifacts.
5. Count `vault/**/*.md` by folder to distinguish compiled page coverage from raw retrieval coverage.
6. Query `site-data/wiki-search.sqlite` counts for `notes`, `compiled_chunks`, `raw_evidence_chunks`, and `embeddings`.
7. Verify a direct `knowledge_base_query` returns the expected result kinds (`compiled_page`, `compiled_chunk`, `raw_evidence_chunk`).

## Pitfalls found in the population audit

- The change watcher must rebuild retrieval as well as graph/static output. The robust watcher path includes `build_agent_index.py`, `build_search_index.py --with-embeddings`, and `lint_wiki.py`; otherwise web pages can be newer than the RAG index.
- Usage-guide extraction must match both current `## Logic — ...` headings and legacy `## Logic:` headings; otherwise `vault/documents/hermes-usage-guides.md` can silently underpopulate.
- If `SOURCE_PATHS` and docs list sources like `SOUL.md` or profiles, confirm they are actually emitted into compiled vault pages. Current generator emits `vault/documents/hermes-soul.md` and `vault/documents/hermes-profiles.md`.

## Recommended robust population flow

The safest full refresh path should include:

```bash
python3 scripts/generate_vault.py
python3 scripts/build_graph.py
python3 scripts/build_agent_index.py
python3 scripts/build_search_index.py --with-embeddings
python3 scripts/lint_wiki.py --write-report --fail-on critical
python3 scripts/build_knowledge_base.py
```

Only run `setup_runtime.py` / `docker compose up` when the task includes site deployment/runtime refresh. Do not modify hosting when the operator explicitly says to stick to retrieval/population logic.
