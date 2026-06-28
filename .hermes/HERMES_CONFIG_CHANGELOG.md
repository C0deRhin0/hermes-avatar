# Hermes Configuration Changelog Template

Use this file for durable, operator-relevant changes to the Hermes harness, configuration, wrappers, cron jobs, skills, SOUL, and workspace policy.

## Entry format

```markdown
## YYYY-MM-DD — Short change title

- **Scope:** affected component(s)
- **Change:** what changed and why
- **Security/privacy impact:** credentials, access, data, or exposure implications
- **Verification:** concrete commands, test results, or observed evidence
- **Rollback:** safe reversal path, if applicable
```

## Initial portable baseline

- **Scope:** repository template
- **Change:** created a credential-free Hermes configuration baseline suitable for adaptation to a new environment.
- **Security/privacy impact:** live credentials, identities, routing identifiers, runtime state, session data, and logs are excluded.
- **Verification:** review the repository's privacy scan and archive validation before publishing.
- **Rollback:** remove the target deployment's local configuration files; no live deployment state is included here.
