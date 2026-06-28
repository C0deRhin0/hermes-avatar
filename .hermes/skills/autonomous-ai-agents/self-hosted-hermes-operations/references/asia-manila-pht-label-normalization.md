# Asia/Manila `PHT` label normalization on self-hosted Hermes

Use this note when Hermes or Knowledge Base outputs show `PST` for timestamps that are actually `Asia/Manila` / `UTC+08:00`.

## Symptom

Human-readable output may show strings like:
- `2026-07-06 08:52:57 PST (+0800)`
- `Run timestamp: ... PST (Asia/Manila)`

This is misleading: the offset and configured zone are Manila, but `%Z` is wrong.

## Verified pattern from VPS session

Live checks that mattered:
- `/etc/localtime` resolved to `/usr/share/zoneinfo/Asia/Manila`
- `timedatectl show -p Timezone --value` returned `Asia/Manila`
- Python local tzinfo rendered as `datetime.timezone(..., 'PST')`
- Numeric offset still rendered as `+0800`

Takeaway: on this class of host, `%Z` alone is not trustworthy for operator-facing labels.

## Durable fix pattern

For operator-facing or wiki-facing timestamp strings:
1. Render the actual local/target time.
2. Verify Manila using stronger evidence than `%Z` alone:
   - explicit zone key when available (`ZoneInfo('Asia/Manila')`)
   - `/etc/localtime` symlink target
   - `timedatectl` timezone
   - `+0800` offset in combination with Manila zone evidence
3. Normalize the human-readable label to `PHT`.

## Good use cases for explicit `PHT`

- cron summaries
- gateway/user-visible timestamp prefixes
- Knowledge Base generated note metadata
- status views and account-reset displays
- operator changelog / audit output

## Avoid

- trusting `strftime('%Z')` alone for Asia/Manila correctness on VPS hosts
- claiming the machine is in Pacific time just because `%Z` says `PST`
- bulk-rewriting historical files unless the user asks; prefer fixing live render paths first

## Related files from the fix session

- Hermes:
  - `hermes_cli/status.py`
  - `hermes_cli/goals.py`
  - `gateway/message_timestamps.py`
  - `agent/account_usage.py`
- Knowledge Base:
  - `scripts/wiki_common.py`
  - `scripts/rebuild_on_change.py`
  - `scripts/generate_vault.py`
