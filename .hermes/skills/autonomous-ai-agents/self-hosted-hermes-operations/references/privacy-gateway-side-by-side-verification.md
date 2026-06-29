# Privacy-gateway side-by-side verification

Use this when validating a privacy-gateway canary in front of Headroom before broad rollout.

## Goal
Prove that the privacy layer improves prompt-side privacy without materially degrading model behavior or breaking the existing Headroom path.

## Recommended comparison shape
Compare two live paths:
- **control:** default profile on the current direct Headroom route
- **experiment:** specialist/researcher profile on the privacy-gateway route

## Minimum prompt set
1. General prompt
2. Technical/debugging prompt
3. Coding prompt
4. Benign prompt containing incidental PII that should not affect the answer
5. Technical prompt containing PII context
6. Longer open-ended prompt
7. One or more exact-output control prompts

## What to inspect
- Did both paths succeed?
- Are outputs semantically equivalent, even if wording differs?
- Did the privacy path introduce malformed structure, missing sections, or weaker instruction following?
- Did returned answers leak the prompt's PII?
- Did benign inputs get over-redacted upstream?

## Live direct-proxy checks
Run direct requests through the privacy gateway without credentials and inspect the redaction findings header:
- benign prompt -> expect low/zero findings
- prompt with real PII -> expect higher findings
- prompt with support-log style masked secrets (for example `ghp_abcd1234...wxyz9876`) -> expect redaction too

A downstream `401 Missing bearer or basic authentication in header` is acceptable for this probe. The purpose is to verify that the privacy gateway saw and transformed the request before Headroom rejected unauthenticated traffic.

## Important pitfall
If repo tests pass but live findings still look wrong, restart the installed `privacy-gateway.service` before concluding the logic failed. The running service may still be the old process.

## Good signs before default rollout
- benign direct probe returns zero findings
- sensitive direct probe returns higher findings
- exact-output control prompts still work on the canary path
- side-by-side prompts show no material quality regression
- Headroom `/stats` continues showing `/v1/responses` traffic on the canary path
