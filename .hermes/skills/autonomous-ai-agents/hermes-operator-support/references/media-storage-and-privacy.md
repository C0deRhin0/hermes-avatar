# Hermes Media Storage & Privacy Notes

Use this reference when answering self-hosted Hermes operator questions about where images/voice notes are stored and what leaves the VPS.

## Storage layers

1. **Messaging platform**
   - Telegram (or another platform) receives the original upload first.
2. **Hermes inbound cache on the VPS**
   - Inbound images/audio are downloaded to local Hermes cache directories.
   - Exact paths may resolve to legacy directories (`image_cache`, `audio_cache`) or the newer `cache/...` layout depending on the install.
3. **Hermes session storage**
   - Message history, transcripts, and metadata persist in `~/.hermes/state.db` unless the profile changes `HERMES_HOME`.
4. **Upstream processing**
   - STT, TTS, vision, browser, or managed-tool gateways may send the asset or derived content upstream if configured.

## What to verify live

- `hermes status --all`
- `config.yaml`:
  - `stt`
  - `tts`
  - `auxiliary.vision`
  - relevant `use_gateway` flags
- resolved cache paths via Hermes helpers (`get_hermes_dir`, `get_hermes_home`)

## Reliable phrasing

- **If attached but not processed:** usually platform + VPS only.
- **If transcribed / analyzed / synthesized by cloud-backed tools:** platform + VPS + upstream provider/tool route.
- **If local STT/TTS/vision is configured instead:** processing can remain on the VPS except for the messaging platform transport itself.

## Common operator expectations

- Users often mean “your end” as either:
  1. the VPS they own, or
  2. third-party providers Hermes calls.

Answer both explicitly.

## Voice-reply follow-through

If the operator asks you to “reply as voice,” actually generate and attach audio in the same turn instead of only describing support.
