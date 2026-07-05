---
name: vps-health-checker
description: Use when checking this VPS for resource pressure, Hermes runtime health, disk growth, or cron/gateway anomalies.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [vps, health, monitoring, hermes, operations]
    related_skills: [backup-auditor, hermes-agent]
---

# VPS Health Checker

## Overview
Use the local `vps-health` wrapper for a fast read-only snapshot of the machine and Hermes runtime.

## When to Use
- User asks for VPS status, health, or capacity
- Cron or gateway behavior seems suspicious
- You need a quick operational snapshot before deeper debugging

## Procedure
1. Run `vps-health` first.
2. Highlight load, memory, disk, Hermes storage growth, gateway state, and cron state.
3. If something is abnormal, recommend the smallest next diagnostic step.
4. Do not mutate configs or services unless the user explicitly approves.
5. When the problem is failed-unit noise rather than live outage, distinguish stale boot-time failures from active service breakage before cleaning anything.

## Failed-unit noise cleanup
When `systemctl --failed` is noisy but the VPS is currently healthy, investigate the failing units before reaching for `systemctl reset-failed` alone.

- Confirm current health first (`vps-health`, gateway status, current network state).
- For `cloud-init.service`, check whether the failure is an old first-boot provisioning error from the NoCloud seed or bootcmd path. On a fully provisioned VPS where cloud-init is no longer wanted, disabling the cloud-init unit chain and creating `/etc/cloud/cloud-init.disabled` is an acceptable permanent cleanup.
- For `systemd-networkd-wait-online.service`, reproduce the exact wait-online command and compare it against `networkctl status <iface>`. If the interface is already routable/online and the wait unit only adds stale noise on this VPS, masking the wait-online unit can be the smallest safe fix.
- After durable fixes, run `systemctl reset-failed` and re-check `systemctl --failed` plus `hermes-gateway.service`.
- Reference: `references/failed-units-cleanup.md`

- Only add passwordless sudo rules when the user explicitly confirms the command and rationale. Do NOT generalize the rule—constrain it to the exact binary/path (e.g., /usr/bin/true) and document rationale in operational notes. Always verify the addition with visudo and check sudoers.d afterward. If sudoers is not readable, report this for operator visibility.
- Do not claim service failure without checking the live wrapper output.
- Do not treat high storage use as urgent without naming which path is large.

## Verification Checklist
- [ ] `vps-health` ran successfully
- [ ] Report includes key resource and Hermes runtime findings
- [ ] Any follow-up recommendation is specific and low-risk
