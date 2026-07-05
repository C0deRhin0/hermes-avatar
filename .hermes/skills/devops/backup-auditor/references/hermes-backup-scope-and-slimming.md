# Hermes backup scope and slimming

Use this note when backup storage suddenly jumps and the user wants both diagnosis and cautious cleanup.

## Proven pattern observed on the operator's VPS
- Daily backups were being created by `~/bin/backup-hermes` into `~/backups`.
- The script included all of `${WORKSPACE_ROOT}`, which allowed a temporary review workspace under `${WORKSPACE_ROOT}/tmp` to inflate backup size.
- The biggest culprits inside the temp workspace were rebuildable artifacts:
  - `*/.venv`
  - `*/target`
  - package caches and similar non-durable material
- Oversized recent tarballs can remain large even after live cleanup because the old archives still contain the deleted content.

## Audit sequence
1. Inventory backups by timestamp and size.
2. Report total backup directory size, not just latest archive size.
3. Inspect the cron/job definition and backup script scope.
4. Check for sudden size jumps across recent archives.
5. Correlate the jump with large live paths such as:
   - `${WORKSPACE_ROOT}/tmp`
   - `~/.cache`
   - `~/.npm`
   - repo-local `.venv`, `target`, `.pytest_cache`, `node_modules`

## Good exclusion candidates for this environment
- `${WORKSPACE_ROOT}/tmp`
- `*/.venv`
- `*/target`
- `*/.pytest_cache`
- `*/node_modules`
- `~/.cache`
- `~/.npm`
- `~/.hermes/sandboxes/docker`

## Cautious cleanup sequence after approval
1. Patch backup scope first so the next archive is slim.
2. Syntax-check the script.
3. Run one fresh backup.
4. Spot-check the new tarball contents to confirm the bulky transient paths are absent.
5. Only then prune the oversized recent archives.

## Extra caution
- Missing optional directories such as `~/.opencode` or `~/.codex` should be handled conditionally instead of turning a backup into a warning-producing run.
- Permission-sensitive files or secrets that produce tar warnings should be explicitly excluded or otherwise handled before declaring the archive healthy.
- The standard tar notice about removing leading `/` from member names is expected and not itself a failure.
