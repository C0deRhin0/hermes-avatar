# Public Static Site Hardening (Caddy / Docker)

Use this note when a VPS-hosted static site is already deploying correctly but still needs a tighter browser-facing and route-level security baseline.

## When this is the right class of fix

- The site is static HTML/CSS/JS (for example Next.js static export under `out/`)
- The user asks whether the public web is "safe" or asks for hardening against script attacks
- You have already verified that the site loads and the change should preserve that behavior

## Baseline questions to answer from live evidence

1. Are all scripts/styles/assets self-hosted, or are there third-party origins?
2. What security headers are actually present on the live route right now?
3. Does the route accept unnecessary methods such as `POST`?
4. Is the site static-only, or are there public APIs/forms/login paths that need a broader policy?

Do not answer from theory alone — inspect the built HTML and the live response headers.

## Good baseline for a self-hosted static portfolio

If the exported site uses only same-origin assets, a strong starting CSP is:

```text
Content-Security-Policy: default-src 'self'; base-uri 'self'; object-src 'none'; frame-ancestors 'none'; img-src 'self' data:; style-src 'self'; script-src 'self'; font-src 'self'; connect-src 'self'; media-src 'self'; manifest-src 'self'; form-action 'none'
```

### Inline-style caveat for React/Next static UIs

Do not assume `style-src 'self'` is safe for every static export. Some React/Next portfolios use visible inline style attributes such as `style={{ ... }}` for layout, animation, z-index, or pointer-state behavior. In that case a CSP that blocks inline styles can make UI sections appear missing or visually broken even while the page still returns `200` and shows no obvious JS errors.

When tightening CSP:

1. inspect the codebase for inline style usage before finalizing `style-src`
2. after applying CSP, visually check the live page — not just headers and status codes
3. if the site currently depends on inline styles, temporarily use:

```text
style-src 'self' 'unsafe-inline'
```

4. keep `script-src 'self'` strict while planning a later refactor to remove inline-style dependence if the goal is a tighter CSP

Useful companion headers:

```text
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Cross-Origin-Opener-Policy: same-origin
Cross-Origin-Resource-Policy: same-origin
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), geolocation=(), microphone=()
Strict-Transport-Security: max-age=31536000
```

Optional fingerprint reduction:

```text
-Server
```

## Method restriction for static routes

If the route is truly static, consider allowing only read methods:

```text
GET
HEAD
```

Reject others with `405` and an `Allow` header.

This does not stop DDoS, but it narrows needless request behavior on the public route.

## Important Caddy/Docker gotcha

If the container runs Caddy with `admin off`, then:

- `caddy validate` can still succeed
- `caddy reload` can fail because there is no admin API on `localhost:2019`

In that case the apply sequence is:

1. validate config
2. recreate the service (`docker compose up -d --force-recreate <service>`)
3. re-check live headers and page behavior

## What this does and does not protect against

### Helps with
- reducing browser-side script injection blast radius
- clickjacking / framing protection
- limiting cross-origin abuse surface
- reducing accidental exposure from permissive defaults
- reducing unnecessary HTTP verb handling

### Does not solve
- volumetric DDoS / large floods
- VPS compromise
- DNS takeover / registrar abuse
- supply-chain compromise in the build process

For real DDoS absorption, you need an upstream CDN/WAF/provider mitigation layer.

## Verification checklist

- Built page still loads with expected title/body marker
- Live route returns `200`
- Live headers include CSP and the intended companion headers
- `Server` header is absent if intentionally removed
- Negative-method probe (for example `POST`) returns `405`
- If using Caddy-in-Docker with `admin off`, verify by recreate + live probe, not by assuming reload succeeded
