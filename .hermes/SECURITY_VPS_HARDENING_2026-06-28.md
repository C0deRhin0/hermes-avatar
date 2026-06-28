# VPS Security Hardening Template

This template intentionally contains no deployment-specific hostnames, addresses, accounts, or security findings.

## Baseline checklist

- Keep the host patched and review exposed services regularly.
- Use least privilege for service accounts, filesystem permissions, and tool access.
- Keep secrets in a secure local store; do not place them in Git, logs, or chat transcripts.
- Bind internal services to loopback or a private network unless public exposure is explicitly required.
- Protect messaging and email integrations with explicit routing and approval controls.
- Maintain tested backups and a documented restore procedure.
- Review gateway, proxy, and service logs for unintended data disclosure.
- Reassess firewall rules, SSH policy, and service units after meaningful infrastructure changes.

Document deployment-specific evidence in private operator records, not in this public template.
