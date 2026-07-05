---
name: backup-auditor
description: Use when auditing Hermes/VPS backups for freshness, size, and obvious retention issues without modifying backup files.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [backup, audit, retention, hermes, vps]
    related_skills: [vps-health-checker]
---

# Backup Auditor

## Overview
Audit backup outputs non-destructively. Focus on whether backups exist, how old they are, how large they are, and whether retention looks unhealthy.

## When to Use
- User asks whether backups are healthy
- A recurring job needs to report backup freshness
- Storage growth suggests backup sprawl

## Procedure
1. Inspect `~/backups` for recent artifacts.
2. Report latest backup timestamp, file size, rough backup count, and total backup directory size.
3. If growth looks abnormal, inspect the backup job definition and backup script scope to see what is actually being archived.
4. Compare recent archive sizes to identify sudden jumps instead of treating backup growth as uniform drift.
5. Correlate backup growth with large live paths on the VPS, especially temp workspaces, build outputs, virtualenvs, package caches, and other rebuildable directories.
6. Recommend cleanup or repair actions, but do not delete anything without approval.
7. If the operator approves cleanup, create a fresh verified backup before pruning unusually large recent archives.

## Common Pitfalls
- Do not assume backup integrity from file presence alone.
- Do not remove old backups unless the user explicitly approves deletion.
- Do not stop at `~/backups` size alone; check whether the backup script is unintentionally archiving `${WORKSPACE_ROOT}/tmp`, `*/.venv`, `*/target`, `node_modules`, or user caches.
- Do not prune the newest oversized backups until a newer slim backup succeeds and its contents are spot-checked.
- Treat tar warnings from missing optional paths, live-mutating files, or permission-sensitive secrets as a signal to tighten backup scope before calling the archive healthy.

## Session Notes / References
- `references/hermes-backup-scope-and-slimming.md` — backup bloat investigation pattern, exclusion candidates, and cautious prune sequence validated on the operator's VPS.

## Verification Checklist
- [ ] Latest backup file, age, count, and total backup dir size reported
- [ ] Retention/growth concerns called out if present
- [ ] Backup job/script scope inspected when growth is abnormal
- [ ] Likely live-path growth culprit named when identifiable
- [ ] No destructive action taken without approval
