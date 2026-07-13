# Windows Unicode Banner Distortion

## Scenario

A Next.js terminal-style portfolio rendered its knowledge_base/banner art correctly on:

- macOS laptop display
- macOS external 24-inch monitor
- phone browser

But the same banner appeared distorted on:

- Windows laptop screen
- Windows laptop driving the same 24-inch external monitor

The bug reproduced on both the local build and the public deployment.

## Diagnostic value of the symptom pattern

This pattern strongly points away from:

- server/deployment misconfiguration
- responsive width bugs caused by one specific monitor
- public-only caching or proxy issues

And toward:

- OS/browser font rendering differences
- missing deterministic webfont delivery
- Unicode glyph fallback differences

## Root cause pattern

The banner was rendered from a `<pre>` using a large amount of Unicode beyond plain ASCII, including:

- Braille patterns
- block/shade elements

CSS named `Source Code Pro`, but the app did not actually set up a reliable webfont-loading path for that banner. Different platforms therefore fell back differently. Windows rendered some glyphs with different fallback metrics, causing visible distortion.

## Fix pattern

Use a dedicated webfont for the sensitive banner instead of relying on the general app font stack.

In the recorded case, the fix was:

- load `Noto Sans Mono` with `next/font/google`
- expose it via a CSS variable such as `--font-knowledge_base-art`
- apply that variable only to the banner
- set `letter-spacing: 0`
- set `font-variant-ligatures: none`
- loosen `line-height` slightly (for example from `1.05` to `1.15`)
- keep a fallback stack with Windows-friendly monospace fonts (`Cascadia Mono`, `Cascadia Code`, `Consolas`)

## Verification pattern

- rebuild the app successfully
- inspect computed style of the banner to confirm the intended font is actually used
- visually inspect the banner after the font change
- ask for a re-check on the originally broken Windows browser/device

## Important lesson

If `font-family` names a font but the app never actually loads it, the UI is still system-font-dependent. That is often invisible on the developer’s own machine and only surfaces as cross-platform distortion later.
