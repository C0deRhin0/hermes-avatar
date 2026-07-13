---
name: project-summarizer
description: Use when a repo or workspace needs a compact summary of structure, stack, commands, risks, and likely next actions.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [repo, summary, architecture, onboarding]
    related_skills: [opencode-executor, sop-generator]
---

# Project Summarizer

## Overview
Produce a compact technical summary of a repo so the operator can quickly understand what it is, how it runs, and where the risk lies.

## When to Use
- User asks what a repo does
- You need a quick handoff or architecture brief
- A workspace review cron job needs concise project notes

## Procedure
1. Read the repo root docs and inspect the top-level tree.
2. Identify stack, entry points, test/build commands, and notable config.
3. Summarize current state in a compact, structured format.
4. Call out unknowns and high-risk areas instead of guessing.

## Common Pitfalls
- Do not infer stack details without reading actual files.
- Avoid giant file inventories; summarize the parts that matter.

## Verification Checklist
- [ ] Summary names the stack and entry points
- [ ] Test/build commands are included when discoverable
- [ ] Risks or unknowns are explicitly stated
