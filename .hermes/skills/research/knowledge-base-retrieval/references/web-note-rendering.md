# Knowledge Base Web Note Rendering

## Trigger
Use when the operator reports that clicked Knowledge Base pages look like raw/unrendered Markdown or that page text formatting is hard to read.

## User correction from 2026-06-30
the operator clarified that this is **not** a request for visual redesign or security re-architecture. The issue is strictly text formatting/presentation: Markdown syntax in clicked pages should be rendered into proper HTML for clarity.

Do not over-expand into graph visuals, CMS choices, or Tailnet security unless explicitly asked.

## Durable recommendation
Render Markdown to HTML at **static build time** so clicked wiki pages are formatted documents rather than raw-looking Markdown.

Preferred shape:

```text
vault/*.md
  -> build-time Markdown renderer
  -> static HTML under dist/vault/*.html
  -> Caddy serves generated HTML
```

## Current known-good implementation pattern
- Renderer file: `${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/build_knowledge_base.py`.
- Dependencies in `requirements.txt`:
  - `markdown-it-py>=3.0`
  - `bleach>=6.1`
- Render with `MarkdownIt('commonmark', {'html': True})`, then sanitize the rendered HTML with an explicit Bleach allowlist.
- Useful embedded raw HTML such as `details`, `summary`, `kbd`, `mark`, tables, and images may render; active content such as scripts, event handlers, styles, and `javascript:` URLs must be stripped.
- Convert Obsidian wikilinks before render:
  - `[[path/to/note]]` -> `vault/path/to/note.html`
  - `[[path/to/note|label]]` -> label text with same href
- Keep arbitrary/raw active HTML disabled by sanitizer policy; do not bypass the allowlist.
- Demote body headings so the note-page shell remains the only `h1`.
- Full `open note` pages must not put truncated excerpts or filler labels such as `Complete compiled note body below` in the page header. Render the complete compiled vault note body directly after the header; keep truncation only in graph previews, retrieval snippets, cron attention excerpts, or explicitly labeled source summaries. Session notes should be compiled wiki artifacts, not raw transcript dumps: `One-line summary`, metadata/status, `Main Ideas`, `Decisions`, `Outcome`, `Key Facts`, `Follow-ups / Open Tasks`, and `Linked Context`. If session-summary or memory note bodies still contain `…`, inspect `scripts/summarize_sessions.py` and `scripts/generate_vault.py` for upstream `clean(..., limit)` truncation.
- Add CSS only for formatting clarity in `src/assets/site.css`:
  - tables
  - blockquotes
  - code blocks / inline code
  - nested lists
  - task-list checkboxes

## TDD regression pattern
Add focused tests before changing production renderer code:

```text
tests/test_build_knowledge_base_rendering.py
```

Minimum behaviors to test:
- bold, italic, inline code render as HTML;
- Markdown tables render as `<table>`, `<th>`, `<td>` and raw pipe rows disappear;
- blockquotes render as `<blockquote>` rather than escaped `>` text;
- task lists render checkboxes rather than raw `[x]` / `[ ]`;
- Obsidian wikilinks render as internal HTML links;
- `render_note_page()` output contains rendered HTML, not raw Markdown syntax.
- safe embedded HTML renders while script/event-handler/`javascript:` payloads are stripped;
- full note pages contain the complete compiled body and no truncated header excerpt.

## Generator truncation triage
When `open note` still appears incomplete after the renderer is fixed:

1. Inspect the generated vault note under `vault/` first. If the vault Markdown already contains `...`/`…`, the problem is upstream generation/summarization, not static HTML rendering.
2. Keep graph/retrieval previews short, but do not reuse preview excerpts as the full note-page header/body.
3. For source-derived documents such as usage guides and changelog decision pages, preserve full captured sections/summaries unless the page is explicitly a summary/archive excerpt by design.
4. Add regression tests that assert a long marker survives into the rendered body and that the note-page header contains no ellipsis.

## Verification commands
Run focused checks first, then rebuild:

```bash
cd ${WORKSPACE_ROOT}/hermes-memory-wiki
PYTHONPATH=scripts python3 -m pytest tests/test_build_knowledge_base_rendering.py -q -o 'addopts='
python3 -m py_compile scripts/build_knowledge_base.py
python3 scripts/generate_vault.py
python3 scripts/build_graph.py
python3 scripts/build_agent_index.py
python3 scripts/build_search_index.py --with-embeddings
python3 scripts/lint_wiki.py --write-report --fail-on critical
python3 scripts/build_knowledge_base.py
node --check src/assets/app.js
```

If Hermes asks for explicit ad-hoc verification evidence, create and run a literal `/tmp/hermes-verify-*.py` script that asserts rendered HTML contains markers such as `<table>`, `<blockquote>`, `<strong>`, `<code>`, sanitized safe HTML such as `<details>`/`<summary>`, no active HTML payloads, no raw table pipe rows for a representative page, and no truncated excerpt in the note-page header.

## Pitfalls
- Do not solve this by editing wiki content; the content is valid Markdown source.
- Do not expose raw Markdown files or add client-side raw Markdown parsing as the default path.
- Do not do a visual redesign unless the operator separately asks for one.
- Do not enable arbitrary raw HTML execution. If raw HTML support is needed, keep it sanitizer-allowlist based and covered by tests.
