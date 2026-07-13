---
name: weekly-ai-research-radar
description: "Prepare the operator's weekly AI Research Radar as a private Knowledge Base research-archive briefing."
version: 1.1.0
platforms: [linux]
created_by: agent
related_skills: [url-link-analysis, youtube-link-analysis, youtube-content, hermes-agent, llm-wiki]
metadata:
  hermes:
    tags: [research, weekly-briefing, ai, youtube, wiki, cron]
---

# Weekly AI Research Radar

## When to use

Use for the operator's recurring weekly research task about new AI technologies, agent workflows, models, tools, use cases, and operator-relevant changes.

The coverage should be **AI in general first**. Hermes/VPS/Knowledge Base relevance should be highlighted only when genuinely present.

## Output posture

Keep the output private and local-first:

1. Deliver a concise summary to the operator in Telegram.
2. Save the primary report as a Knowledge Base research note under `vault/research/`.
3. Optionally mirror the Markdown into `${WORKSPACE_ROOT}/ai-research-radar/weekly/`.
4. Do **not** publish a separate `research.example.invalid` surface unless the operator explicitly approves it later.

## Expected weekly flow

1. Get the current timestamp in `Asia/Manila`.
2. Read `${WORKSPACE_ROOT}/ai-research-radar/sources.yaml` if present.
3. Research current AI news, blogs, docs, repos, and practical tooling changes.
4. Search for high-signal YouTube/video items and fetch transcripts locally where useful.
5. Rank findings by practical value to the operator:
   - usefulness to current/future workflows
   - cybersecurity and operations relevance
   - local-first / privacy-preserving implementation potential
   - maturity, effort, and risk
6. File the report under:

```text
${WORKSPACE_ROOT}/hermes-memory-wiki/vault/research/YYYY-WW-ai-research-radar.md
```

7. Rebuild Knowledge Base so the note appears in the research archive graph.

## Weekly report shape

```markdown
# AI Research Radar — YYYY-WW

## Executive summary
- <top themes of the week>

## High-signal findings
### 1. <title>
- Why it matters
- Relevance to the operator
- Suggested next action

## YouTube / transcript-backed items
- <video + transcript status + takeaways>

## Hermes / VPS / Knowledge Base opportunities
- Only include if genuinely relevant

## Watchlist
- <things to revisit later>
```

## Guardrails

- Do not force every finding to be Hermes-related.
- Do not auto-change code, DNS, Caddy, cron, credentials, or public exposure from the report.
- If transcript retrieval or source access fails, report the failure plainly.
- Treat the weekly radar as a research/archive workflow, not a publishing workflow.

## Schedule example

The current preferred cron expression is:

```cron
50 1 * * 0
```

That means every **Sunday at 01:50 PHT / GMT+8**.
