---
name: youtube-content
description: "YouTube transcripts to summaries, threads, blogs."
platforms: [linux, macos, windows]
---

# YouTube Content Tool

## Data Provenance and Robust Research/Assessment
- Always attempt to fetch the full transcript using youtube-transcript-api for YouTube URLs; make assessment based on the transcript, not just any available summary.
- If transcript fetching fails (auth required, quota, no captions provided), fallback to high-quality, structured summaries, clearly annotating this in outputs.
- For security-critical escalations (burner Google account for headless/auth scraping): Prefer not to log in unless absolutely necessary, only use non-personal credentials, and notify operator if account, IP, or fingerprint may be at risk. Abandon escalation if detection/banning risks outweigh research value.

- ### Template for documenting URL research provenance (add to session analysis or operator usage reports):

| Source Type   | Provenance                |
|--------------|--------------------------|
| YouTube      | transcript, summary, both |
| Blog/Article | full text, summary, both  |
| Web Post     | full text, summary, both  |

Always include the table or an equivalent note to clarify which research artifact was actually used for analysis.
- For blog, article, and plain web URLs, always attempt to extract the main content and perform research-level analysis. Do not restrict the deep analysis workflow to YouTube URLs—apply it to all research URLs where full text can be extracted.
- For dynamic, JS-heavy, or bot/captcha-protected sites, escalate from plain extraction to headless browser scraping only if permitted and safe, and only after free/unauthenticated methods are exhausted.
- If the user flags excessive verbosity, include a pitfall: default to concise summary tables and bullet lists unless otherwise requested.

### Pitfall: Verbose or verbose-by-default agent responses
- When the user signals frustration, impatience, or requests less verbosity (e.g., 'tf is that reply', 'just give me the answer'), explicitly default to concise replies for the rest of the session and flag for skill/operational update. User style corrections are SKILL.md-grade learnings. Do not treat them as mere memory facts.

Use when the user shares a YouTube URL or video link, asks to summarize a video, requests a transcript, or wants to extract and reformat content from any YouTube video. Transforms transcripts into structured content (chapters, summaries, threads, blog posts).

Extract transcripts from YouTube videos and convert them into useful formats.

## Setup

Prefer `uv` when available so the dependency is installed into the same Hermes-managed environment that runs the helper script. On hosts where `uv` is not installed but `youtube-transcript-api` is already available to `python3`, use the direct `python3` commands below.

```bash
# Preferred when uv exists
uv pip install youtube-transcript-api

# Fallback when uv is missing
python3 -m pip install --user youtube-transcript-api
```

## Helper Script

`SKILL_DIR` is the directory containing this SKILL.md file. The script accepts any standard YouTube URL format, short links (youtu.be), shorts, embeds, live links, or a raw 11-character video ID.

```bash
# JSON output with metadata
python3 SKILL_DIR/scripts/fetch_transcript.py "https://youtube.com/watch?v=VIDEO_ID"

# Plain text (good for piping into further processing)
python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --text-only

# With timestamps
python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --timestamps

# Specific language with fallback chain
python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --language tr,en

# If uv is available, the same commands can be run as:
uv run python3 SKILL_DIR/scripts/fetch_transcript.py "URL" --timestamps --text-only
```

## Output Formats

After fetching the transcript, format it based on what the user asks for:

- **Chapters**: Group by topic shifts, output timestamped chapter list
- **Summary**: Concise 5-10 sentence overview of the entire video
- **Chapter summaries**: Chapters with a short paragraph summary for each
- **Thread**: Twitter/X thread format — numbered posts, each under 280 chars
- **Blog post**: Full article with title, sections, and key takeaways
- **Quotes**: Notable quotes with timestamps

### Example — Chapters Output

```
00:00 Introduction — host opens with the problem statement
03:45 Background — prior work and why existing solutions fall short
12:20 Core method — walkthrough of the proposed approach
24:10 Results — benchmark comparisons and key takeaways
31:55 Q&A — audience questions on scalability and next steps
```

## Workflow

1. **Fetch** the transcript using the helper script with `--text-only --timestamps` via `uv run python3` when available, or direct `python3 SKILL_DIR/scripts/fetch_transcript.py` when the dependency is already installed in the active Hermes environment.
2. **Validate**: confirm the output is non-empty and in the expected language. If empty, retry without `--language` to get any available transcript. If still empty, tell the user the video likely has transcripts disabled.
3. **Chunk if needed**: if the transcript exceeds ~50K characters, split into overlapping chunks (~40K with 2K overlap) and summarize each chunk before merging.
4. **Infer intent agnostically**: do not assume the video is about Hermes or any other expected topic just because of recent conversation. Analyze what the transcript actually covers and answer in chat by default.
5. **Transform** into the requested output format. If the user did not specify a format, default to a concise inference report: TL;DR, key ideas, practical takeaways, reliability/caveats, and follow-up questions.
6. **Approval gate for documents**: only if the content appears relevant to Hermes, the local VPS setup, Knowledge Base, AI-agent harnesses, skills/tools, cron/webhooks, or operator workflow, ask the user whether to file a research/archive note or potential harness-upgrade document. Do not create a Markdown/wiki document from an ad-hoc YouTube link without explicit approval.
7. **Verify**: re-read the transformed output to check for coherence, correct timestamps, and completeness before presenting.

## Error Handling

- **Transcript disabled**: tell the user; suggest they check if subtitles are available on the video page.
- **Private/unavailable video**: relay the error and ask the user to verify the URL.
- **No matching language**: retry without `--language` to fetch any available transcript, then note the actual language to the user.
- **Dependency missing**: run `uv pip install youtube-transcript-api` and retry.
