#!/usr/bin/env python3
"""Verify Knowledge Base generated session notes stay useful second-brain artifacts.

Run from any directory. Exits non-zero when generated session notes regress into
placeholder/raw transcript-like pages or rendered HTML loses required sections.
"""
from __future__ import annotations

from pathlib import Path

ROOT = Path('${WORKSPACE_ROOT}/hermes-memory-wiki')
VAULT_SESSIONS = ROOT / 'vault' / 'sessions'
DIST_SESSIONS = ROOT / 'dist' / 'vault' / 'sessions'

REQUIRED_MD_HEADINGS = [
    '## One-line summary',
    '## Main Ideas',
    '## Decisions',
    '## Outcome',
    '## Key Facts',
    '## Follow-ups / Open Tasks',
    '## Linked Context',
]
REQUIRED_HTML_MARKERS = [
    '<h3>Main Ideas</h3>',
    '<h3>Decisions</h3>',
    '<h3>Outcome</h3>',
    '<h3>Key Facts</h3>',
    '<h3>Follow-ups / Open Tasks</h3>',
]
RAW_TASK_WALL_MARKERS = [
    '[Your active task list was preserved across context compression]',
    '- [>]',
    '- [ ]',
]
PLACEHOLDER_MARKERS = [
    'Session summary for Knowledge Base archive.',
    'No main ideas extracted.',
]
WEAK_SUMMARIES = {
    'proceed now.',
    'proceed with all.',
    'continue.',
    'please continue.',
}


def fail(message: str) -> None:
    print(f'FAIL: {message}')
    raise SystemExit(1)


def ok(message: str) -> None:
    print(f'OK: {message}')


def section(text: str, start: str, end: str) -> str:
    if start not in text or end not in text:
        return ''
    return text.split(start, 1)[1].split(end, 1)[0]


def main() -> None:
    notes = sorted(VAULT_SESSIONS.glob('*.md'))
    if not notes:
        fail(f'no generated session notes found under {VAULT_SESSIONS}')

    failures: list[str] = []
    for page in notes:
        text = page.read_text(encoding='utf-8', errors='replace')
        positions = [text.find(h) for h in REQUIRED_MD_HEADINGS]
        if any(pos < 0 for pos in positions):
            missing = [h for h, pos in zip(REQUIRED_MD_HEADINGS, positions) if pos < 0]
            failures.append(f'{page.name}: missing headings {missing}')
        elif positions != sorted(positions):
            failures.append(f'{page.name}: session headings out of order {positions}')

        if any(marker in text for marker in PLACEHOLDER_MARKERS):
            failures.append(f'{page.name}: placeholder summary/main-idea marker remains')

        summary = section(text, '## One-line summary', '\n\n-').strip().lower()
        if summary in WEAK_SUMMARIES:
            failures.append(f'{page.name}: weak generic one-line summary {summary!r}')

        main_ideas = section(text, '## Main Ideas', '## Decisions')
        if any(marker in main_ideas for marker in RAW_TASK_WALL_MARKERS):
            failures.append(f'{page.name}: raw task-wall marker leaked into Main Ideas')

        outcome = section(text, '## Outcome', '## Key Facts')
        if '## ' in outcome.replace('## Outcome', ''):
            failures.append(f'{page.name}: nested markdown heading inside Outcome bullets')

    if failures:
        for item in failures:
            print(f'FAIL: {item}')
        raise SystemExit(1)
    ok(f'{len(notes)} generated session notes have required schema and no placeholder/raw-task-wall regressions')

    html_pages = sorted(DIST_SESSIONS.glob('*.html'))
    if not html_pages:
        fail(f'no rendered session HTML pages found under {DIST_SESSIONS}')
    sample_failures: list[str] = []
    for html_page in html_pages[: min(3, len(html_pages))]:
        html = html_page.read_text(encoding='utf-8', errors='replace')
        for marker in REQUIRED_HTML_MARKERS:
            if marker not in html:
                sample_failures.append(f'{html_page.name}: missing rendered marker {marker}')
        if any(marker in html for marker in PLACEHOLDER_MARKERS + RAW_TASK_WALL_MARKERS):
            sample_failures.append(f'{html_page.name}: placeholder/task-wall marker appears in rendered HTML')
    if sample_failures:
        for item in sample_failures:
            print(f'FAIL: {item}')
        raise SystemExit(1)
    ok('sample rendered session HTML pages expose semantic sections and no placeholder/task-wall markers')
    print('SESSION_NOTE_SCHEMA_VERIFICATION_OK')


if __name__ == '__main__':
    main()
