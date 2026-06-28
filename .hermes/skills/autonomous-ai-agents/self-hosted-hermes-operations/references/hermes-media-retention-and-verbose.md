# Hermes media retention, privacy, and verbose-mode notes

This reference captures concrete operational details learned while working on a self-hosted Hermes VPS deployment.

## Media cache paths observed

Typical resolved paths on this install:

- images: `~/.hermes/image_cache`
- audio: `~/.hermes/audio_cache`
- videos: `~/.hermes/cache/videos`
- documents: `~/.hermes/cache/documents`
- session DB: `~/.hermes/state.db`

## Retention behavior pattern

Observed code-path pattern:

- image cache: built-in cleanup exists
- document cache: built-in cleanup exists
- audio cache: do not assume cleanup exists
- video cache: do not assume cleanup exists

Operational lesson: verify each cache type independently before telling the user that Hermes cleans up after itself.

## Quiet cleanup automation pattern

A good production-safe pattern for media retention is:

- script in `~/.hermes/scripts/cleanup-hermes-media-cache.sh`
- delete stale audio by days
- delete stale video by days
- cron job with `no_agent=True`
- `deliver=local` to avoid noisy chat messages
- script stays silent when zero files are deleted

This reduces risk of VPS disk bloat while keeping chat uncluttered.

## Privacy boundary framing

When explaining uploaded media flow, split it into three layers:

1. transport platform copy (e.g. Telegram)
2. local VPS cache copy
3. upstream provider processing copy, if STT/TTS/vision is cloud-backed

This framing is clearer than saying assets are simply "local" or "uploaded."

## Verbose mode and cost

Useful distinction:

- `/verbose` usually changes **tool-progress presentation**
- it does **not automatically imply major extra model-token usage**
- total usage can still rise indirectly if verbose output causes more follow-up turns or longer debugging sessions

When answering cost questions, separate:

- direct model token impact
- indirect session-length impact

## Timezone reminder for self-hosted cron

If the user wants cron behavior in a local timezone like PHT:

- set Hermes timezone explicitly
- then re-save/re-edit existing cron jobs
- verify `next_run_at` shows the intended offset

Do not assume changing config alone retroactively fixes already-scheduled jobs.
