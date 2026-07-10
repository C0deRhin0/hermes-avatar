# Shared Knowledge Base profile provenance

Use this note when the operator asks whether multiple Hermes profiles share the same Knowledge Base, whether provenance is merely documented or actually implemented, or how to verify it after a rebuild.

## Current operating model
- Knowledge Base stays **one shared wiki** at `${WORKSPACE_ROOT}/hermes-memory-wiki`.
- Profiles stay separate in Hermes state (`config.yaml`, `.env`, sessions, memory, cron, auth, etc.).
- Separation inside the wiki should happen by **content type and provenance**, not by cloning the vault into per-profile trees.

## Implemented provenance signals
### Generated session notes
- Source DBs can include both:
  - `${HOME}/.hermes/state.db`
  - `${HOME}/.hermes/profiles/<profile>/state.db`
- Generated `vault/sessions/*.md` notes can stamp:
  - `source_profile`
  - `source_agent_role`
- The note body can also echo the source profile/role for easy visual verification.

### Cron archive notes
- Shared `vault/cron-archives/YYYY-MM-DD.md` notes can aggregate outputs from:
  - `${HOME}/.hermes/cron/output`
  - `${HOME}/.hermes/profiles/<profile>/cron/output`
- Archive notes can stamp:
  - `source_profiles`
  - `source_agent_roles`
- Table/detail rows can show which profile produced a run.

### Retrieval/index layer
- `vault/_meta/agent-index.json` and `site-data/wiki-search.sqlite` should preserve profile provenance so retrieval can distinguish specialist-origin content.
- Raw evidence from profile session DBs may also carry inline `source_profile:` markers for auditability.

## Verification checklist
1. Rebuild Knowledge Base artifacts after the provenance change.
2. Verify at least one generated `vault/sessions/*.md` note from the target profile contains `source_profile: <profile>`.
3. Verify the body of that note mentions the source role if expected.
4. Verify agent-index/search artifacts contain profile provenance, not just policy docs.
5. Distinguish **implemented generated provenance** from the separate question of whether older manual notes were backfilled.

## Important nuance
- Generated pipeline notes/indexes can be provenance-aware even if older manually-authored notes in `vault/research/` are not yet backfilled.
- Provenance is attached per originating Hermes session row, not inferred from the topic alone. If the operator discusses a researcher answer later in the default profile, that default chat can correctly generate its own default-sourced session note while the original researcher session still generates a researcher-sourced note. That is parallel capture, not provenance bleed.
- For future manual durable notes filed into the shared research archive, continue to use frontmatter such as:

```yaml
source_profile: researcher
source_agent_role: research-specialist
```

## Related files
- `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/summarize_sessions.py`
- `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/generate_vault.py`
- `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/build_agent_index.py`
- `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/build_search_index.py`
- `${WORKSPACE_ROOT}/hermes-memory-wiki/KNOWLEDGE_BASE_SPEC.md`
- `${HOME}/.hermes/HERMES_USAGE_GUIDES.md`
- `${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md`
