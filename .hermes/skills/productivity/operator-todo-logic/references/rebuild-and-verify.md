# Rebuild-safe operator TODO workflow

## What changed on 2026-06-29
A manual wiki note at `vault/documents/operator-todo-index.md` looked correct at first, but Knowledge Base rebuilds removed it because the generator did not recreate that note. The durable fix was to treat `${HOME}/OPERATOR_TODO.md` as canonical and update `scripts/generate_vault.py` to regenerate:

- `operator-index.md`
- `vault/documents/operator-todo-index.md`

## Durable rule
If a TODO must appear in Knowledge Base after rebuilds, fix the generator, not just the generated output file.

## Verification pattern
After changing this workflow:
1. Rebuild Knowledge Base.
2. Use a focused `/tmp/hermes-verify-*.sh` script to verify:
   - canonical queue exists
   - repo mirror exists
   - generated vault note exists
   - built HTML exists
   - live HTTPS route returns 200
   - relevant cron prompts reference the canonical queue/path
3. Report the result as **ad-hoc verification**, not suite-green.

## Related cron lesson
When a path matters operationally, encode it directly in cron/job prompts or scripts (for example `${HOME}/backups/`) instead of relying on assistant memory.