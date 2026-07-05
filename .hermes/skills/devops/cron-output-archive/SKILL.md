---
name: cron-output-archive
description: Maintain Knowledge Base daily cron run archives from Hermes cron output while keeping routine scheduled checks out of general session notes.
version: 1.0.0
created_by: agent
related_skills: [knowledge-base-retrieval, vps-health-checker, hermes-agent]
metadata:
  hermes:
    tags: [cron, cron-archive, operations, knowledge-base]
---

# Cron Output Archive

## When to use
Use when the operator asks about cron-result storage, daily cron audits, scheduled VPS/ping/morning brief outputs, or Knowledge Base noise from routine cron sessions.

## Policy
- Routine cron results should **not** become general `vault/sessions/` notes.
- Daily cron audit pages belong under:

```text
${WORKSPACE_ROOT}/hermes-memory-wiki/vault/cron-archives/YYYY-MM-DD.md
```

- Source output files remain canonical raw cron evidence under:

```text
${HOME}/.hermes/cron/output/
```

- Promote only high/critical cron findings into durable project/decision/operator-TODO pages.

## Workflow
1. Inspect cron jobs with `cronjob(action='list')` and verify PHT/+08:00 next-run times when schedules are changed.
2. Inspect daily archive pages first for audits:
   - `${WORKSPACE_ROOT}/hermes-memory-wiki/vault/cron-archives/YYYY-MM-DD.md`
3. If more detail is needed, read the original output file named in the archive row under `${HOME}/.hermes/cron/output/<job_id>/...`.
4. If archive generation changes, update:
   - `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/generate_vault.py`
   - `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/summarize_sessions.py` if cron session filtering changes
   - `${WORKSPACE_ROOT}/hermes-memory-wiki/KNOWLEDGE_BASE_SPEC.md`
   - `${WORKSPACE_ROOT}/hermes-memory-wiki/vault/SCHEMA.md`
   - `${HOME}/.hermes/HERMES_USAGE_GUIDES.md`
   - `${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md`
5. Keep archive pages compact:
   - OK runs appear only in the daily summary table.
   - Warning/critical/error runs get short attention-item details.
   - Do not add a full per-run details section for routine OK runs.
6. Rebuild Knowledge Base and verify:
   - cron archive pages exist by PHT day
   - no `*cron*` files remain under `vault/sessions/`
   - `vault/index.md` lists `Cron Archives`
   - graph/search/lint rebuild passes without critical issues

## Verification commands
```bash
cd ${WORKSPACE_ROOT}/hermes-memory-wiki
python3 -m py_compile scripts/generate_vault.py scripts/summarize_sessions.py
python3 scripts/generate_vault.py
python3 scripts/build_graph.py
python3 scripts/build_agent_index.py
python3 scripts/build_search_index.py --with-embeddings
python3 scripts/lint_wiki.py --write-report --fail-on critical
```

## Pitfalls
- Do not archive routine cron output into always-prominent project/decision pages; it creates retrieval noise.
- Do not delete raw cron output files unless the operator explicitly approves retention cleanup.
- Do not mistake warning keywords inside successful rebuild/lint text for high/critical incidents; classify only explicit errors, script failures/timeouts, high/critical warnings, or human-actionable watch items.
- If a cron archive/rebuild watcher fingerprints cron output, exclude the watcher job's own output from the watched source set; otherwise a successful rebuild can create cron output that triggers the next rebuild forever.
