# Themed banner replacement notes

## When this pattern applies
- A banner/logo is currently rendered from Unicode text, font-dependent glyphs, or fragile CSS/effects.
- The user already has approved theme-specific artwork.
- Existing commands/toggles must keep working after the rendering swap.

## Practical pattern used
- Keep the existing `asciiEnabled` conditional to preserve `ascii on/off` semantics.
- Read the current theme state already used by the terminal.
- Add a `theme -> asset path` mapping in the component.
- Point the banner `<img>` at the mapped asset instead of a hardcoded single image.

## Why this mattered in the portfolio case
- A rough generated PNG was visually unacceptable even though the implementation direction was correct.
- The user explicitly cared about preserving terminal commands, not just making the banner display consistently.
- The supplied theme assets were better than trying to recreate the brand art procedurally.

## Asset guidance
- Prefer transparent PNGs when possible so the terminal background and theme styling can harmonize behind the artwork.
- If only JPGs are available temporarily, wire them first for behavior verification, then swap to transparent PNGs later without changing command logic.
- If Telegram/chat previews show a white box or flattened background, treat that preview as non-canonical and ask for the original files or a zip archive.
- Verify the real files by checking pixel dimensions and alpha presence before final integration.

## First-switch latency mitigation
- If a new device shows a noticeable delay on the first `theme` change, the likely cause is first-time fetch/decode of the alternate banner asset.
- Preload all themed banner assets on initial page load with `new Image().src = ...` so the first user-initiated switch feels instant.
- After adding preloading, verify on a fresh page load that all themed banner resources are requested before the first manual theme switch.

## Verification pattern
- Build the app.
- Verify the component references the themed asset map.
- Verify at least one theme switch changes the loaded asset path.
- Verify the banner is still gated by the existing show/hide condition.
- If preloading was added, verify the alternate assets are already warmed on first load.
