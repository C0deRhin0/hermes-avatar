# Security Hardening Session Details — 2026-06-28

## Scope
Automated implementation and verification of baseline security controls on Ubuntu VPS (kernel 6.8, Ubuntu 24.04).

## Actions Taken
- Backed up `/etc/ssh/sshd_config` before changes
- Set `PasswordAuthentication no` and `PermitRootLogin no` (explicitly, not commented)
- Changed SSH port to 22999, updated UFW to allow, attempted to remove legacy port 22
- Verified UFW: default deny (incoming); allowed 22999/tcp, 443/tcp; 80/tcp denied.
- Tested for and started Fail2Ban; confirmed active
- Verified `unattended-upgrades` enabled
- Attempted to install livepatch tools; **not available for kernel 6.8**

## Key Verification Output
- `/etc/ssh/sshd_config` after edits:
    - Port 22999
    - PermitRootLogin no
    - PasswordAuthentication no
- UFW status after changes
    - Port 22999/tcp (new SSH) open
    - 22/tcp rules present (can remove after alternate SSH port tested by operator)
    - 443/tcp open; 80/tcp denied
- Fail2Ban: enabled and running
- Kernel livepatch: Canonical/Pro not supported, fallback to manual patch/reboot

## Operator/Agent Notes
- IPv6 rules for SSH port 22 remain, since full decommission of the legacy port should happen only after alternate port confirmed usable.
- Kernel livepatching pitfall noted (manual patch + reboot required until Ubuntu Pro supports installed kernel).

