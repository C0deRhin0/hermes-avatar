# Knowledge Base Session Note Schema

## Trigger
Use when implementing or reviewing Knowledge Base generated `vault/sessions/*.md` notes, note-page readability, or retrieval quality for session archives.

## User correction from 2026-07-01
the operator emphasized that Knowledge Base is a serious second-brain wiki. Opened session notes should not be raw transcript-like dumps. They should be complete **compiled wiki artifacts**: readable, reliable, and useful to a human, while raw transcript details remain available only through local raw-evidence retrieval.

## Recommended session note shape

```md
# Session Summary - <title>

## One-line summary
A concise statement of what the session was about and why it mattered.

- Date:
- Time:
- Session ref:
- Source:
- Messages:
- Tool calls:
- Status: completed | partial | interrupted | blocked | unknown

## Main Ideas
- 3–7 concise semantic bullets.
- Do not paste raw user prompts or task-list walls.

## Decisions
- Explicit conclusions or choices made.
- Use `No explicit decisions recorded.` when none were found.

## Outcome
- What was accomplished, verified, interrupted, or blocked.

## Key Facts
- Stable facts, user preferences, project state, constraints.
- Use `No durable key facts extracted.` when none were found.

## Follow-ups / Open Tasks
- Remaining actions, blockers, next steps.
- Use `No open follow-ups recorded.` when none were found.

## Linked Context
- Related wiki pages, projects, entities, parent topics, or session refs.
```

## Implementation lessons

- `scripts/summarize_sessions.py` owns generated session note structure.
- `scripts/wiki_common.py::extract_key_facts()` should prefer `Decisions`, `Key Facts`, `Outcome`, and `Follow-ups / Open Tasks` over metadata bullets like Date/Messages.
- `scripts/build_search_index.py` chunks by generic Markdown headings; adding sections improves retrieval `heading_path` quality and does not require hardcoding every section name in the search index.
- Keep `One-line summary` because existing summary extraction recognizes it.
- Treat generic continuation prompts (`proceed now`, `proceed with all`, `continue`) as weak and skip them when a real topical prompt exists.
- Strip raw task-wall artifacts from `Main Ideas`, especially `[Your active task list was preserved across context compression]`, `- [>]`, and `- [ ]` markers.
- Strip Markdown heading markers inside bullet text so an `Outcome` item containing `## Something` does not render as a nested heading.
- Prefer explicit empty markers over silence for missing sections inside otherwise substantive notes; this makes note quality auditable.
- Empty/no-substance sessions should be omitted rather than written as placeholder notes like `Session summary for Knowledge Base archive.` with `No main ideas extracted.`

## Verification pattern

Use TDD. Red tests should prove the old behavior fails before changing code:

- missing `Decisions`, `Key Facts`, or `Follow-ups / Open Tasks`;
- raw prompt-wall/task-list content leaking into `Main Ideas`;
- weak generic prompts becoming one-line summaries;
- Markdown heading syntax surviving inside bullet items;
- `extract_key_facts()` returning metadata bullets before real decisions/facts.

Post-fix checks should include:

```bash
cd ${WORKSPACE_ROOT}/hermes-memory-wiki
. .venv/bin/activate 2>/dev/null || true
PYTHONPATH=scripts python3 -m pytest tests/test_summarize_sessions.py tests/test_wiki_common.py -q -o 'addopts='
PYTHONPATH=scripts python3 -m pytest -q -o 'addopts='
python3 scripts/generate_vault.py
python3 scripts/build_graph.py
python3 scripts/build_agent_index.py
python3 scripts/build_search_index.py --with-embeddings
python3 scripts/lint_wiki.py --write-report --fail-on critical
python3 scripts/build_knowledge_base.py
node --check src/assets/app.js
python3 ${HOME}/.hermes/skills/research/knowledge-base-retrieval/scripts/verify_session_note_schema.py
```

The packaged verifier checks generated `vault/sessions/*.md` and rendered `dist/vault/sessions/*.html` for required section order, absence of placeholder pages such as `Session summary for Knowledge Base archive.`, absence of raw task-wall markers, absence of weak generic one-line summaries, and rendered semantic sections.

If the verification guard requires literal ad-hoc evidence, create a temporary `/tmp/hermes-verify-*.py` script that performs the same checks and clean it up after running.