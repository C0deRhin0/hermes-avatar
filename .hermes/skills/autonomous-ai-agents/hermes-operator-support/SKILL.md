---
name: hermes-operator-support
description: "Use when answering self-hosted Hermes operator questions about sessions, slash commands, cron/timezone behavior, media capabilities, and privacy/storage on messaging gateways. Lead with the exact command or yes/no answer before any explanation."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, self-hosted, telegram, gateway, privacy, sessions, voice, media]
    related_skills: [hermes-agent]
---

# Hermes Operator Support

## Overview

This skill is for practical support questions from a self-hosting Hermes operator using messaging gateways like Telegram. The operator usually wants the shortest path to the answer: the exact slash command, whether a capability works, where data lands, and what leaves the VPS.

The governing rule is: **answer first, verify second**. If the user asks for a simple operational command (`/sessions`, `/resume`, `/restart`, etc.), give the exact command immediately. Only then add concise context or caveats if they materially help.

## When to Use

Use this skill when the user asks about:
- Hermes slash commands, session browsing, resume, restart, gateway behavior
- self-hosted Hermes timezone / cron behavior
- whether Hermes can analyze images, accept voice notes, or reply as audio
- where uploaded media is stored on the VPS
- whether media or transcripts leave the machine for upstream processing
- practical differences between local processing and managed/cloud processing

Do not use this skill for:
- broad contribution/development work inside the Hermes repo
- generic LLM/provider comparisons unrelated to Hermes operation
- coding tasks in an application repo

## Response Style for This Class of Task

### On evidence-driven RTK plugin verification (session 2026-06-27)
- When asked if an internal Hermes plugin (such as RTK) is “running globally” or enabled, do not reply in generalities or with assumed state. Inspect:
  - Presence of the plugin directory and files (`~/.hermes/plugins/NAME/`)
  - Enabled status in `plugins.enabled` under `config.yaml`
  - That no standalone process/service is required (for passive plugins)
  - Gateway/session active state (Hermes is running, so in-proc plugins are live)
- Report results in a concise, evidence-backed summary table like:
  
  | Check             | Result  |
  |-------------------|---------|
  | Plugin installed  | ✅      |
  | Plugin enabled    | ✅      |
  | Passive, global   | ✅      |
  | Independent svc   | N/A     |
  | All agent paths   | ✅      |
- Explain that passive, global plugins don’t run daemon processes and are only active when Hermes is running; this is the normal/expected design.
- If the user requests a live test of plugin enforcement, offer/execute a command intercept demonstration.

**This targets direct plugin/gateway/operator verification.** Encode this style and checklist for all “is X plugin running globally” or “is Y enabled” operational requests.


1. **Lead with the direct answer.**
   - If the user asks for a command, put the command in the first line.
   - If the user asks whether something works, start with `Yes`, `No`, or `It depends`.
2. **Keep the first pass short.**
   - Do not front-load doc-hunting or long explanations for simple operator questions.
   - Extra verification is for configuration-dependent claims, not for obvious command answers.
3. **Use verification only where it changes the answer.**
   - For privacy, storage, provider routing, voice/image capability, cron timing, and tool backends: inspect the live config/status/code path.
   - For basic built-in commands: answer immediately, then verify only if needed.
4. **Separate certainty levels explicitly.**
   - `Hermes capability:` what the product supports in general.
   - `Your current setup:` what this VPS/config is actually doing right now.

## Fast Path: Common Operator Questions

### Session browsing / resume
Answer with the exact command first.

Examples:
- Old chats in gateway: `/sessions`
- Resume current/old named session: `/resume <name>`
- Fresh session: `/new`
- CLI browse: `hermes sessions browse`

### Gateway reloads
If a config/tool change needs the live messaging process to pick it up:
- Gateway chat: `/restart`
- CLI/service side: `hermes gateway restart`

### Capability checks
For questions like “can you analyze pictures?” or “can you take voice input?”
1. Answer yes/no first.
2. Then inspect live status/config when the user is asking about their actual deployment.
3. Distinguish support from current enablement.

## Media, Privacy, and Storage Workflow

See also `references/media-storage-and-privacy.md` for a compact reference on storage layers, live verification points, and phrasing.

When asked where images or voice notes go, explain the path in layers:

1. **Transport layer** — on Telegram (or the messaging platform) first.
2. **Gateway layer** — Hermes downloads the attachment to the VPS.
3. **Session layer** — transcript/message metadata is stored in Hermes session storage.
4. **Processing layer** — the asset or derived text may leave the VPS only if a configured upstream provider/tool is used.

Always separate these cases:
- **Attached but not processed** → typically platform + VPS only
- **Processed by STT/TTS/vision** → platform + VPS + whichever upstream provider/tool handled processing

## Voice / Image Questions: What to Verify

When the user asks about media handling, verify these live:

1. `hermes status --all` or equivalent status output
   - check managed-tool availability
   - check whether STT/TTS are active
2. `config.yaml` sections:
   - `stt`
   - `tts`
   - `auxiliary.vision`
   - `browser`, `web`, and any `use_gateway` flags relevant to the tool path
3. Storage resolution
   - resolve Hermes cache/session paths rather than assuming defaults
4. If needed, inspect code/docs to confirm whether inbound media is cached locally and where transcripts persist

## Practical Answer Pattern for Privacy Questions

Use this structure:

1. **Short answer**
2. **Stored on VPS where?**
3. **Does it leave the VPS?**
4. **What in this current config causes it to leave or stay local?**
5. **If asked, offer a more private local-only alternative**

## Reply-as-Voice Requests

If the user says “reply as voice” or equivalent:
1. Do not merely say voice is supported.
2. Actually generate audio with the TTS tool in the same turn.
3. Attach the resulting media file in the reply.
4. Mention briefly whether that audio was locally synthesized or routed through an upstream TTS provider.

## Timezone / Cron Support Pattern

For cron/time questions on self-hosted Hermes:
1. Check live timezone/config instead of inferring from server locale.
2. Distinguish system timezone from Hermes application timezone.
3. If the user cares about a specific local timezone, say whether the scheduler is interpreting cron in that timezone or not.
4. If you modify config/schedules, verify the next-run timestamp in the target timezone.

## Passive proxy / compression layer support pattern

When the operator asks whether a transport-layer proxy/compression system (for example Headroom) can be inserted *passively* between Hermes and the active model provider, do not accept generic vendor guidance like "just change the API URL" at face value. Treat it as a runtime-resolution question.

Workflow:
1. Identify the **actual active Hermes provider path** first (for example `openai-codex`, plain `openai`, `anthropic`, `openrouter`).
2. Distinguish **saved config** from **runtime credential resolution**. In Hermes, some providers override or supply base URLs from provider-specific auth/runtime code rather than only `model.base_url`.
3. For `openai-codex` specifically, check whether the deployment is using the ChatGPT/Codex backend shape. The key pitfall is assuming `model.base_url` alone controls routing. The durable operator pattern is:
   - verify the live provider is `openai-codex`
   - verify whether Hermes resolves Codex runtime credentials against `https://chatgpt.com/backend-api/codex`
   - when evaluating a passive proxy canary, prefer the provider-specific runtime override path (for example `HERMES_CODEX_BASE_URL`) over a hand-wavy generic OpenAI base-URL claim
   - preserve provider mode semantics (`codex_responses` / Codex-style routes) when proposing the proxy URL
4. Separate the answer into:
   - **conceptually applicable?**
   - **applicable to this Hermes provider/runtime path?**
   - **safest reversible canary path?**
5. When possible, verify with evidence from both sides:
   - Hermes live config/status/runtime code path
   - proxy repo/docs/tests/health checks

For this class of task, the best operator answer is usually: yes/no first, then a short explanation of the exact integration seam and the lowest-risk canary path.

Reference: `references/codex-passive-proxy-integration.md`.

## Common Pitfalls

1. **Over-verifying trivial command questions.**
   If the user asks for a built-in command like session browsing, answer with the command immediately instead of doing a long doc pass first.

2. **Mixing product support with live deployment state.**
   “Hermes supports voice input” is not the same as “your current STT route is enabled and working.” State both separately.

3. **Giving vague privacy answers.**
   Always distinguish Telegram/platform storage, VPS cache/storage, and upstream provider processing.

4. **Saying voice output is possible without sending voice output.**
   If the user asked for a voice reply, generate and attach the file.

5. **Hardcoding cache paths without checking compatibility layout.**
   Hermes may use legacy cache directories (`image_cache`, `audio_cache`) or newer `cache/...` paths. Resolve them from the active install before claiming exact paths.

## Verification Checklist

- [ ] The first line answers the user’s actual question directly
- [ ] Command answers include the exact slash/CLI command when applicable
- [ ] Capability claims are separated from current-config claims
- [ ] Privacy/storage answers distinguish platform, VPS, and upstream processing
- [ ] Exact local paths were verified before being stated
- [ ] If the user asked for voice output, an audio file was actually attached
