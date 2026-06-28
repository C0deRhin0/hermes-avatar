# Hermes Usage Guide Template

This is the current, portable operating guidance for this harness. Keep it concise and replace outdated guidance rather than retaining conflicting instructions.

## Safe deployment baseline

1. Copy `config.yaml.template` to a local `config.yaml`.
2. Supply credentials through a secure local secret store or `.env`; never commit them.
3. Configure messaging, email, phone-linked services, and other external integrations only after reviewing their permissions and recipient routing.
4. Start with least-privilege tool access and explicit approval for destructive actions and external communication.
5. Store session history, logs, databases, caches, and runtime locks outside version control.

## Project-local OpenCode usage

- Place the project-local OpenCode harness in `.opencode/`.
- Perform Git operations inside `codebase/`.
- Use bounded automation where possible, inspect resulting changes, and run appropriate tests before treating a task as complete.

## Privacy gateway posture

A privacy gateway can provide a controlled intermediary for model traffic. Keep that component isolated, restrict it to the necessary network boundary, and verify routing and logs before enabling it for a live profile. This repository contains no gateway credentials or deployment-specific routing information.
