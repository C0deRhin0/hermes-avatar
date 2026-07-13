# Hermes Avatar

Hermes Avatar is a portable, privacy-conscious configuration harness for a VPS-hosted [Hermes Agent](https://github.com/NousResearch/hermes-agent) operator.

It captures the durable operating model behind a practical, long-running agent: a local-first workspace, reusable skills, an operator SOUL, project-scoped OpenCode automation, and safeguards for handling privileged integrations without placing credentials or personal runtime state in source control.

## Operating goals

- **Reproducible agent operations** — keep the operator instructions, skills, plugins, scripts, and configuration templates needed to rebuild a working Hermes environment.
- **Privacy by design** — provide a clean configuration baseline while excluding API keys, OAuth credentials, Telegram identifiers, email tokens, session history, logs, databases, caches, and other sensitive runtime state.
- **Capability with boundaries** — support a VPS resident agent with controlled filesystem access and approved integrations such as Gmail/email, phone-linked messaging, and Telegram-based communication, while preserving explicit approval boundaries for destructive actions, production changes, and external communications.
- **Layered context efficiency** — retain the configuration patterns used for context-compression layers (including Headroom and RTK), durable skills, and retrieval-oriented operator knowledge without exporting private conversation data.
- **Network separation** — document a privacy-gateway-oriented architecture that can mediate model traffic. The companion implementation is [privacy-gateway](https://github.com/C0deRhin0/privacy-gateway). This harness is designed for VPS operation and does not grant access to the operator's personal machine.
- **Project-local automation** — use one `.opencode/` harness per project and keep application git operations within `codebase/`. The OpenCode harness used with this Hermes setup is also maintained as the reusable [OpenCode Cheatscale project](https://github.com/C0deRhin0/opencode-cheatscale).

## Layout

```text
hermes-avatar/
├── .opencode/                 # project-local OpenCode harness
└── codebase/                  # Git repository root
    ├── .hermes/               # portable Hermes configuration baseline
    │   ├── config.yaml.template
    │   ├── SOUL.md
    │   ├── skills/
    │   ├── plugins/
    │   ├── scripts/
    │   └── operator documents
    ├── .gitignore
    └── README.md
```

## What is intentionally excluded

This repository must never contain live credentials, OAuth files, `.env` files, account identifiers, Telegram routing data, Gmail/email tokens, phone numbers, private session content, logs, state databases, model caches, or running-service artifacts. `config.yaml.template` is generated as a portable starting point and uses placeholders for values that must be supplied locally.

Cron job state is also excluded: scheduled jobs can deliver external messages and should be recreated deliberately for each deployment.

## Deployment posture

1. Clone or copy this repository to a trusted VPS workspace.
2. Review `codebase/.hermes/config.yaml.template`, then create a local `config.yaml` and replace placeholders using the target environment's secure secret store or `.env` file.
3. Add credentials interactively on the target host; do not copy them between machines or commit them.
4. Review integrations, tool permissions, and messaging routes before starting the gateway.
5. Use the project-local `.opencode/` harness for bounded codebase work.

## Security notes

The harness is configuration, not a backup of a live agent. A functioning deployment must be independently reviewed for least privilege, secure service configuration, network exposure, backup posture, and approval controls.
