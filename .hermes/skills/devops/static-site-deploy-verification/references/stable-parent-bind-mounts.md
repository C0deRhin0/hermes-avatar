# Stable parent bind mounts for static exports

Use this note when a static site is built into a generated directory such as `out/` or `dist/` and served from a long-lived Docker container.

## Durable lesson
Do **not** bind-mount the generated export directory itself when the build tool may replace that directory inode.

Bad pattern:
- host mount source: `/srv/www/portfolio/out`
- container root: `/srv/portfolio`

Safer pattern:
- host mount source: `/srv/www/portfolio`
- container root: `/srv/portfolio`
- web root inside container: `/srv/portfolio/out`

## Why
Some static export workflows replace `out/` atomically or by deleting/recreating it. A running container can stay attached to the old deleted inode and show symptoms like:
- public `404`
- container-visible served directory empty
- `/proc/self/mountinfo` showing a source ending in `//deleted`

## Verification recipe
1. Check host build artifact exists:
   - `stat /srv/www/portfolio/out`
   - `test -f /srv/www/portfolio/out/index.html`
2. Check runtime mount source:
   - `docker inspect <container> --format '{{json .Mounts}}'`
3. Check container mount state:
   - `docker exec <container> sh -lc 'grep "/served/path" /proc/self/mountinfo'`
4. Check served file exists inside container:
   - `docker exec <container> sh -lc 'test -f /srv/portfolio/out/index.html && echo ok'`
5. Check public response:
   - `curl -I -L https://example.com`
   - body/title probe to confirm expected artifact, not just HTTP 200

## Session-backed example
A public portfolio on `example.invalid` and `portfolio.example.invalid` was healthy on-host but returned `404` publicly because the Caddy container mount pointed to `/srv/www/portfolio/out//deleted`. Rebinding the container to `/srv/www/portfolio` and serving `/srv/portfolio/out` fixed the recurrence class, not just the immediate outage.
