---
name: asset-driven-ui-replacements
description: Replace fragile text/Unicode/UI effects with asset-driven components while preserving existing app controls, themes, and toggles.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [ui, frontend, assets, theming, cross-platform, verification]
    when_to_use:
      - A UI element renders inconsistently across operating systems or browsers because it depends on Unicode glyphs, font fallback, or visual effects.
      - The user wants a banner/logo/artwork replaced with supplied image assets.
      - The app already has theme toggles or show/hide commands that must continue working after the replacement.
---

# Asset-Driven UI Replacements

## Goal

When a fragile UI element should become image/asset-driven, preserve the product behavior first and swap only the rendering layer. The replacement must match the user's real artwork closely, not a rough approximation.

## Core Rules

1. **Use the user's real assets whenever available.**
   - Do not invent a rough substitute if the user can provide the real artwork.
   - If an earlier generated asset is visibly off, treat it as a temporary placeholder only.

2. **Preserve existing controls and commands.**
   - Before changing rendering, inspect how visibility, theme, state, and commands are wired.
   - If the app has toggles like `ascii on/off` or `theme 1/2/3`, the new asset layer must still respond to them.

3. **Separate artwork from container styling.**
   - Prefer transparent assets when the surrounding UI already owns the background.
   - Let CSS/container styles handle spacing, backdrop, glow, and layout when possible.

4. **Theme by selection, not by approximation.**
   - If the app has discrete themes, map theme state directly to discrete assets unless a verified dynamic tinting approach is clearly better.
   - Example pattern: `theme -> asset path` map inside the component.

5. **Match the current visual identity before optimizing.**
   - The first success condition is fidelity to the existing banner/logo/art.
   - Only after fidelity is correct should you optimize file type, transparency, or responsive polish.

## Workflow

1. Inspect the current render path.
   - Find the component that renders the fragile element.
   - Find the state/commands that control visibility and theme.

2. Identify compatibility constraints.
   - Confirm which commands, localStorage values, CSS variables, and theme IDs must still work.

3. Decide the asset strategy.
   - Single asset if all themes share one visual.
   - Per-theme assets if the artwork differs by theme.
   - Prefer transparent PNG/WebP when SVG generation/export is unavailable and the user already has raster artwork.
   - When chat apps recompress or flatten image backgrounds, ask for the real assets as files or a zip archive and use those instead of the in-chat preview.

4. Validate the source assets before wiring them.
   - Check dimensions, mode, and transparency/alpha on the delivered files.
   - Treat chat-preview JPEGs and screenshots as visual references only, not canonical implementation assets.
   - If the user says fidelity matters, do not stop at a generated approximation once the real files are available.

5. Integrate minimally.
   - Replace only the render path.
   - Keep existing toggle conditions intact.
   - Avoid rewriting unrelated command logic.
   - If theme-specific assets are large enough to cause a noticeable first-switch delay, preload them on initial page load after restoring any persisted theme selection.

6. Verify with real execution.
   - Build the app.
   - Serve locally if needed.
   - Verify the DOM points at the expected asset for each tested theme/state.
   - Confirm the show/hide toggle still gates rendering.
   - On a fresh page load, confirm the alternate themed assets are already requested/warmed if preloading was added.

## Pitfalls

- **Do not ship a placeholder asset as if it were final.** If it does not match the user's banner closely, stop calling it done.
- **Do not implement from Telegram/chat image previews when the transport may have rewritten the file.** Use the original uploaded file or zip when fidelity or transparency matters.
- **Do not ignore existing command semantics.** A pretty asset swap that breaks theme or visibility commands is a regression.
- **Do not bake background panels into the artwork unless that is intentionally part of the design.** If the app already has a themed terminal background, a transparent asset usually integrates better.
- **Do not assume SVG is required for success.** If the environment blocks SVG generation/export, use supplied raster assets and preserve behavior.

## the operator-specific preference

For portfolio/banner replacements, keep replies short when the user asks for short answers, and preserve existing terminal commands and theme behavior instead of solving only the visual problem.

## Support files

- `references/themed-banner-replacement.md` — notes from the portfolio banner case: behavior-preserving asset swap, theme mapping, and transparency guidance.

## Verification checklist

- [ ] The replacement uses the real user-supplied asset or a verified close reproduction.
- [ ] Existing visibility toggles still work.
- [ ] Existing theme controls still work.
- [ ] Build/export succeeds.
- [ ] Local DOM/visual verification confirms the expected asset is active.
