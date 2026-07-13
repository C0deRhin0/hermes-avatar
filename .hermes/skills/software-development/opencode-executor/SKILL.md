---
name: opencode-executor
description: Use when delegating bounded coding work to OpenCode, especially for repos under ${WORKSPACE_ROOT}/Github.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [opencode, coding, github, harness]
    related_skills: [opencode, project-summarizer]
---

# OpenCode Executor

## Overview
Use the `opencode-task` wrapper for bounded coding work. It enforces the `${WORKSPACE_ROOT}` boundary. For GitHub project work it requires a project-local harness at `${WORKSPACE_ROOT}/Github/<project>/.opencode/` and runs OpenCode from the project root while the actual repository/source tree lives under `${WORKSPACE_ROOT}/Github/<project>/codebase/`.

## Approved OpenCode locations
- **Primary allowed root:** `${WORKSPACE_ROOT}` only. The wrapper refuses anything outside this tree.
- **GitHub project wrapper target:** `${WORKSPACE_ROOT}/Github/<project>/codebase` for repo/source work.
- **GitHub project harness:** `${WORKSPACE_ROOT}/Github/<project>/.opencode/` seeded from `${WORKSPACE_ROOT}/.opencode-master`.
- **Canonical master harness:** `${WORKSPACE_ROOT}/.opencode-master` for installs/sync only; do not run coding tasks there unless explicitly maintaining the harness itself.
- **Non-GitHub workspace trial/approved bounded work:** `${WORKSPACE_ROOT}/<name>` when the workspace exists and the task is scoped to that repo/workdir.
- **Token ping workspace:** `${WORKSPACE_ROOT}/opencode-ping` for scheduled smoke/token pings only, not real code work.

## When to Use
- User asks for implementation, refactoring, or code review in a workspace repo
- You want a bounded OpenCode run instead of an interactive TUI

## Procedure
1. Confirm the target path is under `${WORKSPACE_ROOT}` and exists.
2. For GitHub repos, target the source tree (`${WORKSPACE_ROOT}/Github/<project>/codebase`). If `${WORKSPACE_ROOT}/Github/<project>/.opencode/opencode.json` is missing, first run:
   - `opencode-harness-install ${WORKSPACE_ROOT}/Github/<project>`
3. Run:
   - `opencode-task <repo-or-workdir> "<task>"`
4. For GitHub repos, expect the wrapper to `cd` to `${WORKSPACE_ROOT}/Github/<project>`, verify the harness config, and then invoke `opencode run` with the configured model.
5. For non-GitHub workspaces, expect the wrapper to `cd` directly to the supplied `${WORKSPACE_ROOT}/<name>` path. Use a workspace-local `.opencode/` harness only when explicitly installed/trialed for that workspace.
6. After the run, verify actual changed files and run tests yourself when needed.
7. Report repo path, task, files changed, tests run, and follow-up risks.

## Command Pass-Through Mode

When the operator explicitly asks Hermes to invoke a project-defined OpenCode slash command and **only forward OpenCode's result**:

1. Do not read or paraphrase that command's source file to reproduce its behavior.
2. Invoke it through `opencode-task <project>/codebase '/command arguments'` so OpenCode loads and executes the project-local harness itself.
3. Wait for the real OpenCode process to finish.
4. Return the OpenCode result verbatim in a code block, without Hermes analysis, added status claims, or substitute implementation.
5. Preserve normal safety boundaries: do not invoke commands that would create deceptive history, and obtain required approval for destructive actions, production changes, or remote pushes.

## Common Pitfalls
- Never run OpenCode outside `${WORKSPACE_ROOT}`.
- `opencode-harness-install` is intentionally GitHub-project-scoped; it refuses non-`${WORKSPACE_ROOT}/Github/<project>` targets.
- If `opencode-task` is given a GitHub `codebase/` path, it still runs OpenCode from the project root so the project-local `.opencode/` harness is visible.
- Do not report success without checking actual outputs or repo changes, except in explicit command pass-through mode where the user requested OpenCode output only.
- Do not inspect a slash command's source merely to emulate it when the user explicitly requested that OpenCode execute it.

## Verification Checklist
- [ ] `which -a opencode opencode-task opencode-harness-install` resolves expected binaries
- [ ] Wrapper command completed successfully
- [ ] Target path stayed inside `${WORKSPACE_ROOT}`
- [ ] GitHub project harness exists when using `${WORKSPACE_ROOT}/Github/<project>/codebase`
- [ ] Final report used the required 5-part coding summary
