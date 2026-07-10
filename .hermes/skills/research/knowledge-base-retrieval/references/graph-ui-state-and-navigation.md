# Knowledge Base graph UI state, note return, and movement smoothing

Use this when the operator reports Knowledge Base graph UX issues rather than content-generation issues.

## Symptoms this reference covers

- Need a graph `Titles` toggle for both 2D and 3D.
- `open note` sends the user to a full note page, but browser Back or a note-page return action drops them back to the default landing state instead of the graph state they were using.
- `MICRO` needs a wider default zoom-out / 3D camera distance for larger vaults.
- Node labels fade too early in 2D or 3D.
- Toggling `Movement` in 3D causes an initial whole-graph shake before settling.

## Correct implementation layer

These are graph/static-site behavior issues, not vault-content issues.

Primary files:

- `src/assets/app.js` — graph state, URL state, label fade, camera/motion logic, note-return wiring
- `src/assets/site.css` — note-page/topbar/close-button styling
- `scripts/build_knowledge_base.py` — graph controls markup and note-page HTML structure
- `tests/test_build_knowledge_base_rendering.py` — focused static rendering regressions

## Proven implementation pattern

### 1. Preserve graph state in the URL

Persist at least:

- `layout`
- `rendering`
- `movement`
- `titles`
- `filter`
- `zoom`
- `panX`
- `panY`
- `cameraYaw`
- `cameraPitch`
- `cameraDistance`

Use history replacement while adjusting the graph so browser Back returns to the prior graph state instead of a bare default home.

### 2. Make `open note` carry a return URL

When generating note links from the graph/detail panel, append a `return=` query parameter pointing back to the current graph URL. This lets:

- browser Back restore the previous graph state naturally
- a note-page `Close` button explicitly return to the prior graph state

Keep the note-page `Knowledge Base` brand as the intentional default-home link unless the operator asks otherwise.

### 3. Handle note-page `Close` inside `src/assets/app.js`

Do not rely on inline page-specific JS in the generated note page when the shared asset can own the behavior. On note pages:

- detect `#note-close`
- resolve `return=` safely against same-origin only
- fall back to same-origin `document.referrer`
- otherwise fall back to the default `index.html`

### 4. Smoother 3D movement toggles

If movement amplitude and oscillation phase are both derived directly from the current movement scalar, toggling movement in 3D can produce a visible initial shake.

Use a separate accumulated phase variable that advances smoothly over time, and multiply only the motion amplitude by the eased movement scalar.

### 5. Increase label fade tolerance

For complaints that labels disappear too early:

- widen 2D zoom fade thresholds
- widen 3D camera-distance and projected-scale thresholds
- keep `Titles OFF` implemented as label alpha = 0 rather than by mutating node data

### 6. Wider `MICRO` default for large vaults

A practical fix is to lower 2D `MICRO` default zoom and increase 3D default camera distance on entry to `MICRO`, while preserving user-adjusted viewport state when restoring from URL.

## Verification checklist

Run all of these after the change:

- `node --check src/assets/app.js`
- `pytest -q tests/test_build_knowledge_base_rendering.py`
- `python3 scripts/build_knowledge_base.py`
- browser smoke check on the private wiki endpoint for:
  - Titles ON/OFF
  - `MICRO` default viewport
  - note-page `Close`
  - browser Back restoring graph state
  - 3D movement toggle without initial shake

## Pitfalls

- Do not treat graph-state return as the same thing as the note-page brand link; keep `Close`/Back and default-home actions conceptually separate.
- Do not parse numeric URL params with `Number(...) || default` when `0` is a valid value; use explicit finite checks so `panX=0`, `panY=0`, etc. survive restoration.
- Do not document a note-page inline script pattern if the final implementation moved the behavior into shared `app.js`.
- Do not solve early label fade by hard-disabling labels in `MICRO`; adjust the fade thresholds instead.
