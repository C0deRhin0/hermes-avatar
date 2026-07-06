---
name: vps-security-hardening
description: Class-level procedure for securing a Linux VPS against automated attacks, brute-force attempts, and common misconfiguration exploits.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [vps, security, hardening, ssh, firewall, fail2ban, patching]
    related_skills: [vps-health-checker]
---

# VPS Security Hardening

## Overview
Robust VPS security requires layered protections in authentication, firewalling, intrusion detection, and patch management. This skill encodes best practices for public cloud/colo VPS, using Ubuntu/Debian as default examples.

## When to Use
- User requests a security baseline or assessment for a VPS
- Implementing, reviewing, or remediating SSH, UFW, Fail2Ban, or auto-update configuration
- Introducing a new public-facing service on an existing VPS

## Procedure
1. **Backup critical config files before making changes.** Always backup `/etc/ssh/sshd_config` before edits.
2. **SSH Access Control:**
    - Set `PasswordAuthentication no` and `PermitRootLogin no` in `/etc/ssh/sshd_config` (uncomment or add if needed; never assume defaults).
    - Change the SSH port off 22 (e.g., use a high random port; add to firewall before removing 22 rules).
    - Reload/restart SSH with caution; always test alternate port before closing previous port.
3. **Firewall:**
    - Enforce default-deny for incoming. List only essential ports (HTTPS, chosen SSH, others as needed).
    - IPv6 rules must be managed if enabled; never forget to match changes on both stacks.
    - Deny HTTP (80) unless explicitly serving websites.
4. **Fail2Ban:**
    - Install and enable Fail2Ban to monitor failed SSH and other service logins. Confirm it's running.
5. **Automated Security Updates:**
    - Unattended-upgrades is enabled; check status.
6. **Kernel Livepatch:**
    - If available for the current kernel (e.g., Ubuntu Pro LTS), install and verify status. If not, add a pitfall noting manual patching is required.

## Pivotal Pitfalls
- Never lock yourself out: test new SSH port before firewalling off the old one.
- Canonical Livepatch is not available for all kernels; check support on current Ubuntu release and fall back to manual patch/reboot when unsupported.
- Always backup SSH config before edits and document every change to operator.

## Verification Checklist
- [ ] /etc/ssh/sshd_config was backed up and is current
- [ ] Password login and root login are both disabled
- [ ] SSH port migrated and tested; legacy port closed only after test
- [ ] Firewall strict; only needed ports open (both IPv4 and IPv6)
- [ ] Fail2Ban active
- [ ] Unattended-upgrades enabled
- [ ] Kernel livepatch solution present or pitfall noted

## Session/Reference Details
- Additional session-specific test output, error transcripts, or config diffs should be attached under `references/`.
