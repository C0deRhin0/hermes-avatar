---
name: sop-generator
description: Use when turning a repeated technical workflow into a concise, audit-friendly SOP or runbook.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [documentation, sop, runbook, process]
    related_skills: [project-summarizer, hermes-agent]
---

# SOP Generator

## Overview
Create short, operational SOPs that are safe to follow later. Prefer exact commands, prechecks, rollback notes, and verification steps over high-level prose.

## When to Use
- User asks for a manual, runbook, checklist, or standard procedure
- A workflow has become repetitive enough to document

## Procedure
1. State the goal and scope in one sentence.
2. List prerequisites and safety checks first.
3. Write numbered steps with exact commands or UI actions.
4. End with verification and rollback/recovery notes.
5. Keep the SOP concise enough to use under pressure.

## Common Pitfalls
- Avoid vague steps like "check logs" without naming where.
- Do not omit approval boundaries for risky actions.

## Verification Checklist
- [ ] SOP includes prerequisites, steps, verification, and rollback notes
- [ ] Commands and paths are explicit
- [ ] Risky steps clearly require approval
