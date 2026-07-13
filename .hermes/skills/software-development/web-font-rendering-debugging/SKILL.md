---
name: web-font-rendering-debugging
description: Debug cross-platform web UI breakage caused by font loading, fallback, glyph coverage, spacing, ligatures, and Unicode-art rendering differences.
version: 1.0.0
author: Hermes Agent
license: MIT
---

# Web Font Rendering Debugging

## Use when

Use this skill when a web UI looks correct on one OS/browser/device but broken on another, especially when the breakage involves:

- ASCII / pseudo-ASCII / Unicode art
- monospace alignment
- odd spacing, crushed lines, or warped glyphs
- Windows-only rendering problems
- layout that differs between local/public only by client platform
- browser text that appears to use the wrong font even though CSS names a preferred font

## Goal

Find out whether the bug is caused by:

1. missing or inconsistent webfont delivery
2. fallback to different local/system fonts by OS
3. incomplete glyph coverage for the character set in use
4. CSS spacing rules that are too fragile across font metrics
5. ligatures or shaping changing fixed-cell text layout

Then implement the smallest fix that makes rendering deterministic across platforms.

## Procedure

1. **Separate client-rendering bugs from deploy bugs**
   - If the issue reproduces on both local and public builds but only on certain operating systems/devices, prioritize client rendering, font loading, and CSS metrics over deployment theory.
   - If the symptom varies by OS and not by monitor, treat it as an OS/browser text-rendering problem first.

2. **Inspect the text source, not just the screenshot**
   - Find the component and CSS that render the broken text.
   - Check whether the content uses only plain ASCII or also Unicode blocks such as:
     - Braille patterns (`U+2800`–`U+28FF`)
     - Block elements (`U+2580`–`U+259F`)
     - box-drawing or other symbols
   - Unicode-heavy art is much more likely to break under font fallback.

3. **Check whether the preferred font is actually delivered by the app**
   - Do not assume `font-family: 'X', monospace;` means the browser is really using X.
   - Inspect whether the app explicitly loads the font (for example `next/font`, `@font-face`, or a real hosted font import).
   - If there is no webfont loading path, different OSes will substitute different local fonts or fallback glyph providers.

4. **Inspect computed font usage in the browser**
   - Check the rendered element’s computed `font-family`, `line-height`, `letter-spacing`, and ligature settings.
   - If available, inspect loaded font faces with `document.fonts` and verify the intended font is actually loaded.

5. **Look for fragile CSS on fixed-cell art**
   - For banners or terminal art, verify:
     - `white-space: pre`
     - no accidental wrapping
     - `letter-spacing: 0` unless deliberately tuned
     - ligatures disabled
     - line-height not so tight that fallback metrics crush rows

6. **Fix deterministically**
   - Prefer a dedicated bundled/hosted font for the fragile art instead of relying on the app’s general text font.
   - For Next.js, prefer `next/font` and bind the result to a CSS variable used only by the sensitive component.
   - If the art is still fragile, add a fallback stack of known monospaced fonts with better Windows coverage.
   - Loosen line-height slightly if rows appear vertically cramped.
   - Disable ligatures for any fixed-width art.

7. **Verify visually and structurally**
   - Rebuild the app.
   - Inspect the live/local page visually.
   - Confirm the rendered element is now using the intended font stack and spacing rules.
   - When possible, have the user re-check on the affected OS/browser, because cross-platform font fixes are only fully proven on the originally broken platform.

## High-value checks

- Find font-loading mechanism: `next/font`, `@font-face`, hosted font imports
- Search for the exact component and CSS class used by the broken text
- Inspect computed style for:
  - `font-family`
  - `line-height`
  - `white-space`
  - `letter-spacing`
  - `font-variant-ligatures`
- Inspect `document.fonts` to see which faces are loaded
- Determine whether the rendered art uses Unicode glyph classes beyond plain ASCII

## Pitfalls

### 1. Named font in CSS is not proof of real usage
A CSS declaration like `font-family: 'Source Code Pro', monospace;` is not enough. If the app never loads that font, every OS/browser will improvise differently.

### 2. Unicode art is not ordinary monospace text
Braille/block glyph banners are much more sensitive to glyph coverage and font metrics than plain terminal text.

### 3. Monitor size is often a red herring
If the same machine behaves the same on internal and external displays, but a different OS breaks, debug the font stack first.

### 4. Tight line-height can amplify fallback-font ugliness
A line-height that looks fine on macOS can look crushed on Windows if fallback glyph metrics differ.

### 5. Do not overgeneralize from headers/server state
If both local and public builds break the same way only on one client platform, do not blame CSP, deploy drift, or reverse proxy first.

## Good fix patterns

- Dedicated art font loaded with `next/font`
- CSS variable like `--font-knowledge_base-art` used only by the fragile banner
- `letter-spacing: 0`
- `font-variant-ligatures: none`
- slightly looser `line-height`
- fallback stack including Windows-friendly monospace fonts such as `Cascadia Mono`, `Cascadia Code`, or `Consolas`

## Escalation path

If deterministic font delivery still does not stabilize the art on the affected platform, consider replacing the banner with:

1. a simplified ASCII-only glyph set
2. SVG text/vector art
3. a static image for the decorative banner while keeping accessible text separately

## References

- `references/windows-unicode-banner-distortion.md` — notes from a Next.js portfolio case where Unicode knowledge_base/banner art rendered correctly on macOS/iPhone but distorted on Windows due to missing deterministic font delivery and glyph fallback differences.
