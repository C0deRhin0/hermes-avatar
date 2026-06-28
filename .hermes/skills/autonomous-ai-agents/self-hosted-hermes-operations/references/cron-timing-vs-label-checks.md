# Cron timing vs timezone-label checks

Use when a cron delivery looks "wrong day" or "wrong timezone" at first glance.

## Fast verification sequence
1. Check the cron metadata fields: `schedule`, `last_run_at`, `next_run_at`.
2. Check live server time in `Asia/Manila` / `+08:00`.
3. Separate two questions:
   - **Did the job fire at the correct instant?**
   - **Was the human-readable timezone label rendered correctly?**
4. If `last_run_at` / `next_run_at` are correct in `+08:00` but the message says `PST (Asia/Manila)`, classify it as a **labeling bug**, not a scheduling bug.

## Response style for quick operator checks
When the operator asks for a quick/brief check, reply in this order:
1. what the cron is
2. whether timing is correct
3. whether the problem is scheduling vs labeling
4. the shortest actionable conclusion

## Example conclusion
- "Timing is correct; label is wrong."
- "Ran on Friday 08:30 Asia/Manila as scheduled; `PST` should be `PHT`."
