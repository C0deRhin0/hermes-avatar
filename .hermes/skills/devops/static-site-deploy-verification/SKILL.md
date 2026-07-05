---
name: static-site-deploy-verification
description: "Verify that a VPS-hosted static site is actually current after remote pushes: sync git checkout, rebuild artifacts, and prove the live server/container is serving the new files."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [deploy, static-site, git, docker, caddy, verification, vps]
    related_skills: [github-repo-management, vps-health-checker, self-hosted-hermes-operations]
---

# Static Site Deploy Verification

## Use when

Use this skill when the user says any of the following or equivalent:

- "I pushed from another device — is the VPS/site up to date?"
- "Pull the latest changes and check if production matches."
- "The repo may be newer than the live website."
- "Verify my static site deploy on the VPS."

This skill is for the class of work where a repo checkout, build artifact, and public site may drift apart.

## Goal

Prove all three layers, in order:

1. **Git checkout freshness** — is the VPS repo behind remote?
2. **Build artifact freshness** — did the latest revision build successfully?
3. **Serving freshness** — is the live web server/container actually serving that built artifact?

Do not stop at a successful `git pull` or successful local build. The deliverable is a verified live-state answer.

## Procedure

1. **Identify the deployed checkout and remote**
   - Confirm repo path and `origin` URL.
   - Record current branch and current HEAD.

2. **Measure drift before changing anything**
   - `git fetch --prune`
   - Compare `HEAD` vs `origin/<branch>`.
   - Record ahead/behind counts and list incoming commits.

3. **Pull safely**
   - Prefer `git pull --ff-only origin <branch>`.
   - After pull, confirm working tree is clean and note the new HEAD.

4. **Verify the project still builds**
   - Install/update deps only as needed for the repo (`npm ci`, equivalent lockfile-safe install, etc.).
   - Run the real production build/export command.
   - Confirm the expected artifact path exists (`out/`, `dist/`, etc.).

5. **Smoke-test the artifact locally**
   - Serve the built directory locally or use the project’s local preview command.
   - Confirm local HTTP returns `200` and capture minimal evidence (status + first lines/title/marker).

6. **Verify public endpoints separately**
   - Check the actual production URLs.
   - Capture HTTP status and any redirect/failure behavior.
   - If public returns `404`, stale content, or unexpected headers, do not assume the build failed.

7. **If build is good but public is wrong, inspect the serving layer**
   - Read the reverse-proxy/site config to locate the document root or bind mount.
   - If Docker is involved, inspect mounts and then verify **inside the container** that the expected files exist at the mounted target.
   - Compare host artifact path contents vs container-visible path contents.

8. **Conclude with layer-separated status**
   - Git state: fresh or behind?
   - Build state: successful or failing?
   - Live serving state: current, stale, broken, or mis-mounted?

## High-value checks

- `git remote -v`
- `git status --short --branch`
- `git fetch --prune`
- `git rev-parse HEAD`
- `git rev-parse origin/main` (or deployed branch)
- `git rev-list --left-right --count HEAD...origin/main`
- `git log --oneline HEAD..origin/main`
- Production build command
- `stat` on built artifact(s)
- Public `curl -I -L` or equivalent
- Docker/Caddy/Nginx config inspection
- `docker inspect <container>` for bind mounts
- `docker exec <container> ls/stat <mounted-path>`

## Pitfalls

### 1. Build success is not deploy success
A green local build only proves the checkout can build. It does **not** prove the live server is serving that build.

### 2. Host path != container-visible path
A host directory may contain the latest files while the running container still sees an empty or wrong mount target. Always verify the mounted directory **inside the container** before declaring production healthy.

### 3. Directly bind-mounting a replaceable build directory can drift onto a deleted inode
If the public container bind-mounts a generated directory like `/srv/www/portfolio/out` directly, a later static-export build may replace that directory inode. The running container can stay attached to `/srv/www/portfolio/out//deleted`, see an empty tree, and return public `404`s even though the host's current `out/` contains `index.html`.

**Prefer the stable-parent mount pattern:**
- bind-mount the stable project root (for example `/srv/www/portfolio`) into the container
- serve the export from a subpath inside the container (for example `/srv/portfolio/out`)

Verification for this class of issue should include:
- host-side `stat`/`ls` of the build artifact
- `docker inspect <container>` mount source/destination check
- inside-container `/proc/self/mountinfo` check for `//deleted`
- inside-container `test -f /served/path/index.html`
- live HTTPS probe after any container recreate

### 4. HEAD matching remote is still not enough
Even when `HEAD == origin/main`, the public site may still serve stale or broken content because the serving layer was not refreshed, points at the wrong directory, or cannot read the files.

### 5. HTTP 200 on one probe can be misleading
Also check redirects, headers, and representative body markers. A cached, placeholder, or fallback page can look superficially healthy.

### 6. Static sites still need a security review
A static site has a much smaller attack surface than a dynamic app, but it is not attack-proof. When the user asks whether the public site is "safe," explicitly separate:
- **lower-risk classes**: SQL injection, server-side auth bugs, most app-layer RCE paths
- **still-relevant risks**: malicious JS/content injection, reverse-proxy misconfiguration, file exposure, supply-chain compromise in the build, DNS/TLS issues, and DDoS

Also inspect live response headers. For a public static site, call out whether headers such as HSTS, `X-Content-Type-Options`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, and especially `Content-Security-Policy` are present, instead of answering from general theory alone.

If you tighten CSP, verify the page visually as well as by headers/status. A strict `style-src 'self'` can silently break React/Next static UIs that still rely on inline `style={{ ... }}` attributes; in that case the immediate safe correction is often `style-src 'self' 'unsafe-inline'` while keeping `script-src 'self'` locked down.

### 7. Distinguish app-repo commits from live infra changes
When the hardening lives in reverse-proxy / container / VPS config rather than the app repo, say that explicitly. Do not imply the application repository now contains the live protection if it does not.

If the user wants something commit-worthy inside the app repo anyway, a good move is to add a deployment/security documentation file inside the app repo that records:
- the boundary between app code and serving-layer security
- the required live header/method baseline
- the stable-parent mount pattern
- the verification checklist

That preserves repo-side documentation without smuggling Hermes/operator-local files into the app repository.

### 7. CSP hardening can visually break a healthy static app
A stricter CSP can break UI even when all of the following still look healthy:
- repo HEAD matches remote
- build/export succeeds
- public GET returns `200`
- browser console shows no obvious JS errors

For React/Next static exports, check whether the app uses inline `style={{...}}` props or other inline styling patterns before tightening `style-src`. If a new CSP causes "missing UI" or a stripped-looking layout after a security hardening pass:
- compare VPS repo freshness with `origin/<branch>` first so you do not misdiagnose it as stale deploy drift
- inspect the source tree for inline style usage
- inspect the live `Content-Security-Policy` header, not just the config file
- use a browser visual check in addition to status/header checks
- if the app depends on inline styles, restore UI with `style-src 'self' 'unsafe-inline'` as the compatibility fix, then document the tradeoff and note that a future refactor can remove the relaxation

This is a route-level security regression pattern, not a repo-freshness problem.

## Reporting format

For this class of task, report in this order:

1. repo path
2. remote + branch
3. before/after commit state
4. build result
5. public URL result
6. serving-layer finding
7. exact blocker or next fix

## Example lesson captured from practice

A portfolio repo on `/srv/www/portfolio` was 4 commits behind remote. After a fast-forward pull and successful Next.js export build, the public domains still returned `404`. Root cause was not git or build failure; the Caddy container’s bind-mounted serving path appeared empty inside the container despite the host `out/` directory containing `index.html`. The durable lesson: after rebuilding, verify the served mount from *inside* the running container before claiming the website is current.

Reference note: `references/stable-parent-bind-mounts.md` captures the stable-parent bind-mount pattern, the `//deleted` mount symptom, and the verification recipe.

Reference note: `references/public-static-site-hardening.md` captures a practical CSP/header baseline for self-hosted static sites, the `GET`/`HEAD`-only method policy, the `caddy validate` vs `caddy reload` with `admin off` caveat, and the limits of header-only hardening for DDoS.
