---
name: goal-metaprompting
description: Use when preparing a long-running /goal task so Hermes first turns a rough objective into a detailed, constraint-rich prompt with safety limits and verification criteria.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [goal, metaprompting, planning, autonomous, long-running]
    related_skills: [hermes-agent, sop-generator]
---

# Goal Metaprompting

## Overview
`/goal` works best when the prompt is specific enough to constrain a long autonomous run. This skill turns a vague objective into a durable `/goal` prompt with clear deliverables, tooling boundaries, safety limits, verification steps, and completion criteria.

Use this before kicking off long coding, research, refactor, or document-writing work. Default to drafting the `/goal` prompt first; do not jump straight into `/goal` from a one-line request unless the user already supplied all critical constraints.

The local template library for this skill lives at:
- `${WORKSPACE_ROOT}/hermes-ops/templates/goal-prompts.md`

## When to Use
- The user wants to run `/goal`
- The task is long-running, multi-step, or likely to take many turns
- The request is currently too vague for safe autonomous execution
- The user wants a reusable `/goal` prompt for coding, research, or writing

Do **not** use this as the default path for:
- simple factual questions
- one-command checks
- destructive operations
- production changes without explicit approval
- secret handling or credential rotation

## Intake Checklist
Before drafting the final `/goal` prompt, resolve or explicitly label the following:
1. Objective — what should exist when the run is done?
2. Workspace — exact path where work should happen
3. Deliverables — files, reports, code, or artifacts expected
4. Tools — what Hermes may use and what it must avoid
5. Constraints — stack, style, scope, deadlines, privacy, or resource limits
6. Safety limits — what requires approval and what is forbidden
7. Verification — tests, commands, reviews, or success checks
8. Completion criteria — exact conditions for “done”

If the user has not provided enough information, ask only the smallest set of high-impact follow-up questions needed to avoid a bad `/goal` run.

## Procedure
1. **Classify the task.** Decide whether it is primarily coding, research, writing, or mixed.
2. **Extract known constraints.** Pull out paths, preferred tools, safety limits, expected outputs, and any user-specific requirements already in context.
3. **Fill the gaps.** Ask targeted follow-up questions only for missing information that materially affects execution.
4. **Draft the `/goal` prompt.** Write it as a direct, execution-ready instruction Hermes can follow without further interpretation.
5. **Make approval boundaries explicit.** State what Hermes must not do without confirmation.
6. **Add verification and completion criteria.** The prompt must say how results are checked and when the run should stop.
7. **Present the final `/goal` prompt in a fenced block.** Make it easy for the user to reuse or paste directly.

## Output Format
When preparing a `/goal` prompt, use this structure in your response:

1. One-line summary of the intended `/goal` run
2. Missing assumptions or follow-up questions, if any
3. Final `/goal` prompt in a fenced code block
4. Optional short note on why the prompt is safe and well-scoped

## Base Prompt Scaffold
Use this scaffold when writing the final `/goal` prompt:

```text
I want to run a /goal task, but first I want you to help me create the best possible /goal prompt.

My objective is:
<objective>

Please turn this into a detailed /goal prompt with:
- clear objective
- constraints
- expected deliverables
- tools to use
- workspace path
- safety limits
- verification steps
- completion criteria
```

## Drafting Rules
- Prefer exact paths over generic phrases like “the repo” or “the workspace”.
- Prefer named deliverables over vague success conditions.
- State prohibited actions explicitly.
- Keep the prompt opinionated enough to reduce drift, but not so rigid that Hermes cannot adapt to findings.
- If assumptions remain, label them under an `Assumptions:` subsection inside the final `/goal` prompt.
- For coding tasks, include test or validation commands whenever known.
- For research tasks, require assumptions to be clearly labeled and sources/artifacts to be saved.
- For writing tasks, define audience, tone, structure, and final output path.

## Common Pitfalls
- Do not launch `/goal` from a prompt like “build me an app” without metaprompting first.
- Do not leave the workspace path unspecified when file creation is expected.
- Do not omit approval boundaries for production, credentials, external comms, or destructive changes.
- Do not confuse a planning prompt with the final `/goal` prompt; the user needs the execution-ready version.
- Do not treat “done” as subjective; completion criteria should be checkable.

## Verification Checklist
- [ ] Final `/goal` prompt includes objective, constraints, deliverables, tools, workspace, safety, verification, and completion criteria
- [ ] Missing assumptions are either resolved or clearly labeled
- [ ] Risky or destructive actions require explicit approval
- [ ] Output is copy-pasteable into `/goal` with minimal editing
- [ ] Paths and deliverables are concrete enough for an autonomous run
